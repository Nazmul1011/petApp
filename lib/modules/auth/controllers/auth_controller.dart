import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:get_storage/get_storage.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../model/user_model.dart';
import '../services/auth_api_service.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find();

  final AuthApiService _authApi = AuthApiService();
  final GetStorage _storage = GetStorage();
  final AuthTokenService _tokenService = AuthTokenService();

  static const String _gameIdKey = 'device_game_id';
  
  final Rxn<UserModel> user = Rxn<UserModel>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Try to auto-login on startup
    _autoLogin();
  }

  /// Get or create a unique gameId for this device
  String getOrCreateGameId() {
    String? gameId = _storage.read<String>(_gameIdKey);
    if (gameId == null) {
      gameId = const Uuid().v4();
      _storage.write(_gameIdKey, gameId);
    }
    return gameId;
  }

  Future<void> _autoLogin() async {
    final rt = _tokenService.refreshToken;

    if (rt != null) {
      await refreshAccessToken();
    } else {
      await loginWithDevice();
    }
    
    // After login attempt, decide where to go
    handleRouting();
  }

  void handleRouting() {
    final currentUser = user.value;
    if (currentUser == null) {
      // Fallback to initial onboarding if no user found
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    if (!currentUser.onboardingCompleted) {
      // Step 1: Force onboarding completion
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (currentUser.activePetId == null || currentUser.activePetId!.isEmpty) {
      // Step 2: Onboarding done, but no pet profile yet. Go to Payment/Pet Setup flow.
      // Based on user request, the entry point for pet setup is after Payment.
      Get.offAllNamed(AppRoutes.payment);
    } else {
      // Step 3: Fully set up, go to Dashboard
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  Future<bool> loginWithDevice() async {
    isLoading.value = true;
    try {
      final gameId = getOrCreateGameId();
      final response = await _authApi.loginWithDevice(gameId);

      if (response.success && response.data != null) {
        final authData = response.data!;
        
        // Save tokens
        _tokenService.setTokens(
          sessionToken: authData.accessToken, // Using accessToken as sessionToken for now
          accessToken: authData.accessToken,
          refreshToken: authData.refreshToken,
        );

        user.value = authData.user;
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

      // Fetch user profile if not present
      if (user.value == null) {
        await fetchUserProfile();
      }
      return true;
    } else {
      // Refresh failed, maybe logout
      _tokenService.clearTokens();
      return false;
    }
  }

  Future<void> fetchUserProfile() async {
    final response = await _authApi.getMe();
    if (response.success && response.data != null) {
      user.value = response.data;
    }
  }

  Future<void> logout() async {
    await _authApi.logout();
    _tokenService.logOut();
    user.value = null;
  }

  Future<void> completeOnboarding() async {
    final response = await _authApi.updateProfile({
      'onboardingCompleted': true,
      'onboardingStep': 3,
    });
    
    if (response.success && response.data != null) {
      user.value = response.data;
      handleRouting();
    }
  }
}
