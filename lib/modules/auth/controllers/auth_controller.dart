import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/push_notification_service.dart';
import '../model/user_model.dart';
import '../services/auth_api_service.dart';
import '../../subscription/services/subscription_service.dart' as sub_service;

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final AuthApiService _authApi = AuthApiService();
  final GetStorage _storage = GetStorage();
  final AuthTokenService _tokenService = AuthTokenService();

  /// iOS Keychain: survives app delete/reinstall on the same device.
  /// [first_unlock] keeps the item readable after reboot once the device
  /// has been unlocked, which is safer for cold-start login.
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _gameIdKey = 'device_game_id';
  static const String _hasSeenOnboardingKey =
      'has_seen_onboarding_this_install';

  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Try to auto-login on startup
    _autoLogin();
  }

  /// Get or create a unique gameId for this device.
  /// On iOS this is stored in Keychain so it can survive uninstall.
  Future<String> getOrCreateGameId() async {
    // 1. Try reading from Secure Storage (Keychain on iOS)
    String? gameId = await _secureStorage.read(key: _gameIdKey);

    // 2. If not found in Secure Storage, check GetStorage (for migration/existing users)
    if (gameId == null || gameId.isEmpty) {
      gameId = _storage.read<String>(_gameIdKey);
    }

    // 3. If still not found, generate a new random ID
    if (gameId == null || gameId.isEmpty) {
      gameId = const Uuid().v4();
    }

    // 4. Re-write to Keychain so accessibility options stay applied after upgrades
    await _secureStorage.write(key: _gameIdKey, value: gameId);
    _storage.write(_gameIdKey, gameId);

    return gameId;
  }

  Future<void> _autoLogin() async {
    try {
      final rt = _tokenService.refreshToken;
      bool success = false;

      if (rt != null) {
        success = await refreshAccessToken();
      }

      // If refresh failed (e.g. database reset) or no token exists, try device login
      if (!success) {
        await loginWithDevice();
      }
    } catch (e) {
      // Safely catch errors to guarantee we always reach the routing phase
    } finally {
      // After login attempt, decide where to go
      handleRouting();
    }
  }

  void handleRouting() {
    final currentUser = user.value;
    String targetRoute;

    if (currentUser == null) {
      targetRoute = AppRoutes.onboarding;
    } else {
      final hasSeenOnboarding =
          _storage.read<bool>(_hasSeenOnboardingKey) ?? false;

      if (!hasSeenOnboarding || !currentUser.onboardingCompleted) {
        targetRoute = AppRoutes.onboarding;
      } else if (currentUser.activePetId == null ||
          currentUser.activePetId!.isEmpty) {
        // Already on trial/paid → continue pet setup. Otherwise show paywall
        // so the user can start the free trial or subscribe.
        targetRoute = currentUser.hasTrialOrPremium
            ? AppRoutes.welcomeSplash
            : AppRoutes.payment;
      } else {
        targetRoute = AppRoutes.dashboard;
      }
    }

    // Route to the target page
    Get.offAllNamed(targetRoute);

    // Dismiss the native splash screen after the transition animation is complete
    Future.delayed(const Duration(milliseconds: 500), () {
      FlutterNativeSplash.remove();
    });
  }

  Future<bool> loginWithDevice() async {
    isLoading.value = true;
    try {
      final gameId = await getOrCreateGameId();
      final response = await _authApi.loginWithDevice(gameId);

      if (response.success && response.data != null) {
        final authData = response.data!;

        // Save tokens
        _tokenService.setTokens(
          sessionToken:
              authData.accessToken, // Using accessToken as sessionToken for now
          accessToken: authData.accessToken,
          refreshToken: authData.refreshToken,
        );

        user.value = authData.user;
        // Always refresh profile + subscription for this gameId user
        await fetchUserProfile();
        await PushNotificationService.instance.syncWithBackend();
        return true;
      }
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> refreshAccessToken() async {
    final rt = _tokenService.refreshToken;
    if (rt == null) return false;

    final response = await _authApi.refreshTokens(rt);
    if (response.success && response.data != null) {
      final authData = response.data!;

      _tokenService.setTokens(
        sessionToken: authData.accessToken,
        accessToken: authData.accessToken,
        refreshToken: authData.refreshToken,
      );

      // Always refresh profile + subscription after token refresh
      await fetchUserProfile();
      await PushNotificationService.instance.syncWithBackend();
      return true;
    } else {
      // Refresh failed, maybe logout
      _tokenService.clearTokens();
      return false;
    }
  }

  /// Re-authenticate with the persisted gameId and reload subscription state.
  /// Used by the RESTORE purchase flow after reinstall.
  Future<bool> restoreSubscriptionForDevice() async {
    final success = await loginWithDevice();
    if (!success) return false;
    // loginWithDevice already calls fetchUserProfile
    return user.value?.isPremium == true;
  }

  Future<void> fetchUserProfile() async {
    final response = await _authApi.getMe();
    if (response.success && response.data != null) {
      UserModel fetchedUser = response.data!;

      // Also fetch subscription summary to update premium / trial state.
      // `isPremium` = paid only. Trial is limited and tracked separately.
      try {
        final subResponse = await sub_service.SubscriptionService()
            .getSummary();
        if (subResponse.success && subResponse.data != null) {
          final state = subResponse.data!['state'];
          fetchedUser.isPremium = state == 'active';
          fetchedUser.isOnTrial = state == 'trial';
        }
      } catch (e) {
        LoggerService().error('Failed to fetch subscription summary: $e');
      }

      user.value = fetchedUser;
    }
  }

  Future<void> logout() async {
    await PushNotificationService.instance.unregisterFromBackend();
    await _authApi.logout();
    _tokenService.logOut();
    user.value = null;
  }

  Future<void> completeOnboarding() async {
    // Set the local flag to true so we don't show onboarding again for this installation
    _storage.write(_hasSeenOnboardingKey, true);

    final response = await _authApi.updateProfile({
      'onboardingCompleted': true,
      'onboardingStep': 3,
    });

    if (response.success && response.data != null) {
      final isPremium = user.value?.isPremium ?? false;
      final isOnTrial = user.value?.isOnTrial ?? false;
      user.value = response.data;
      user.value!.isPremium = isPremium;
      user.value!.isOnTrial = isOnTrial;
      handleRouting();
    }
  }

  Future<void> switchPet(String petId) async {
    if (user.value?.activePetId == petId) return;

    isLoading.value = true;
    final response = await _authApi.updateProfile({'activePetId': petId});

    if (response.success && response.data != null) {
      // Retain flags — updateProfile response may not include subscription state.
      final isPremium = user.value?.isPremium ?? false;
      final isOnTrial = user.value?.isOnTrial ?? false;
      user.value = response.data!;
      user.value!.isPremium = isPremium;
      user.value!.isOnTrial = isOnTrial;
      user.refresh();
    }
    isLoading.value = false;
  }
}
