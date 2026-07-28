import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/modules/auth/controllers/auth_controller.dart';
import 'package:petapp/modules/payment/models/subscription_plan.dart';
import 'package:petapp/shared/widgets/snack_bar/app_snack_bar.dart';

import '../services/subscription_service.dart';
import '../views/polar_checkout_webview.dart';

class SubscriptionModuleController extends GetxController with BaseController {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final Rx<SubscriptionPlan> selectedPlan = SubscriptionPlan.yearlyRegular.obs;

  /// From `GET /subscription` → `trial.available`.
  final RxBool trialAvailable = false.obs;
  final RxBool isTrialActive = false.obs;

  /// Sync lock so double-taps can't start a second action before `isLoading` rebuilds.
  bool _actionInFlight = false;

  bool get shouldStartFreeTrial =>
      trialAvailable.value &&
      selectedPlan.value == SubscriptionPlan.yearlyRegular;

  String get continueButtonLabel =>
      shouldStartFreeTrial ? 'Start free trial' : 'Continue';

  @override
  void onInit() {
    super.onInit();
    loadTrialAvailability();
  }

  bool _beginAction() {
    if (_actionInFlight || isLoading.value) return false;
    _actionInFlight = true;
    setLoading(true);
    return true;
  }

  void _endAction() {
    _actionInFlight = false;
    setLoading(false);
  }

  Future<void> loadTrialAvailability() async {
    try {
      final response = await _subscriptionService.getSummary();
      if (!response.success || response.data == null) return;

      final data = response.data!;
      final trial = data['trial'];
      if (trial is Map) {
        trialAvailable.value = trial['available'] == true;
        isTrialActive.value = data['state'] == 'trial';
      } else {
        final offer = data['offer'];
        trialAvailable.value =
            offer is Map && offer['trialAvailable'] == true;
        isTrialActive.value = data['state'] == 'trial';
      }
    } catch (_) {
      // Keep defaults; Continue will still attempt paid checkout.
    }
  }

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan.value = plan;
  }

  Future<void> continueSubscription({bool fromOnboarding = false}) async {
    if (!_beginAction()) return;

    try {
      // Ensure we have fresh trial eligibility before choosing a path.
      await loadTrialAvailability();

      if (shouldStartFreeTrial) {
        await _startFreeTrial(
          fromOnboarding: fromOnboarding,
          onConflictStartCheckout: true,
        );
        return;
      }

      await _startPaidCheckout(fromOnboarding: fromOnboarding);
    } catch (_) {
      _endAction();
    }
  }

  /// Close / cancel on the onboarding paywall.
  /// - Trial still available → start it once
  /// - Already on trial/paid → just close the page (no second free trial)
  /// - Otherwise → continue free into pet setup
  Future<void> dismissOnboardingPaywall() async {
    if (!_beginAction()) return;

    try {
      await loadTrialAvailability();

      if (_alreadyHasTrialOrPaid()) {
        _endAction();
        _closePaywallPage(fromOnboarding: true);
        return;
      }

      if (trialAvailable.value) {
        selectedPlan.value = SubscriptionPlan.yearlyRegular;
        await _startFreeTrial(
          fromOnboarding: true,
          onConflictStartCheckout: false,
        );
        return;
      }

      // Keep loader through navigation.
      Get.offNamed(AppRoutes.welcomeSplash);
    } catch (_) {
      _endAction();
    }
  }

  /// Subscription page cancel / back — always just leave, never starts a trial.
  void cancelSubscriptionPage() {
    if (_actionInFlight || isLoading.value) return;
    Get.back();
  }

  bool _alreadyHasTrialOrPaid() {
    final user = AuthController.to.user.value;
    return isTrialActive.value ||
        user?.isOnTrial == true ||
        user?.isPremium == true ||
        user?.hasTrialOrPremium == true;
  }

  void _closePaywallPage({required bool fromOnboarding}) {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }
    if (fromOnboarding) {
      Get.offNamed(AppRoutes.welcomeSplash);
      return;
    }
    Get.offNamed(AppRoutes.dashboard);
  }

  Future<void> _startFreeTrial({
    required bool fromOnboarding,
    bool onConflictStartCheckout = true,
  }) async {
    final authController = AuthController.to;

    final response = await _subscriptionService.startFreeTrial();

    if (!response.success) {
      // Trial already used / active.
      final trialBlocked = response.statusCode == 409;
      if (trialBlocked) {
        trialAvailable.value = false;
        isTrialActive.value = true;
        if (onConflictStartCheckout) {
          await _startPaidCheckout(fromOnboarding: fromOnboarding);
          return;
        }
        // Cancel / close path: just leave — do not grant another free trial.
        _endAction();
        _closePaywallPage(fromOnboarding: fromOnboarding);
        return;
      }

      _endAction();
      showSnack(
        content: response.message.isNotEmpty
            ? response.message
            : 'Failed to start free trial',
        status: SnackBarStatus.error,
      );
      return;
    }

    await authController.fetchUserProfile();
    trialAvailable.value = false;
    isTrialActive.value = true;

    showSnack(
      content:
          'Free trial started — 7 days of limited Pro samples. Subscribe anytime for full access.',
      status: SnackBarStatus.success,
    );

    // Keep the circle loader through navigation — don't restore the label.
    if (fromOnboarding) {
      Get.offNamed(AppRoutes.welcomeSplash);
    } else {
      Get.back();
    }
  }

  Future<void> _startPaidCheckout({required bool fromOnboarding}) async {
    final authController = AuthController.to;

    final response = await _subscriptionService.createCheckoutSession(
      plan: selectedPlan.value.apiValue,
      successUrl: 'https://petapp.example.com/checkout/success',
      cancelUrl: 'https://petapp.example.com/checkout/cancel',
    );

    if (!response.success || response.data == null) {
      _endAction();
      showSnack(
        content: response.message.isNotEmpty
            ? response.message
            : 'Failed to initialize checkout',
        status: SnackBarStatus.error,
      );
      return;
    }

    final checkoutUrl = response.data!['checkoutUrl'] as String;
    final checkoutId = response.data!['checkoutId'] as String?;
    // Unlock while WebView is open so Cancel/close can work after return.
    _endAction();

    final result = await Get.to(
      () => PolarCheckoutWebView(
        checkoutUrl: checkoutUrl,
        successUrl: 'https://petapp.example.com/checkout/success',
        cancelUrl: 'https://petapp.example.com/checkout/cancel',
      ),
    );

    if (result == true && checkoutId != null) {
      if (!_beginAction()) return;
      final validateResponse = await _subscriptionService.validateSubscription(
        checkoutId: checkoutId,
      );

      if (validateResponse.success) {
        await authController.fetchUserProfile();
        showSnack(
          content: 'Subscription activated successfully!',
          status: SnackBarStatus.success,
        );
        // Keep the circle loader through navigation — don't restore the label.
        if (fromOnboarding) {
          Get.offNamed(AppRoutes.welcomeSplash);
        } else {
          Get.back();
        }
        return;
      }

      _endAction();
      showSnack(
        content: 'Failed to validate subscription. Please contact support.',
        status: SnackBarStatus.error,
      );
    } else if (result == false) {
      showSnack(
        content: 'Checkout cancelled.',
        status: SnackBarStatus.error,
      );
    }
  }

  Future<void> restorePurchase() async {
    if (!_beginAction()) return;

    final authController = AuthController.to;

    try {
      final restored = await authController.restoreSubscriptionForDevice();

      if (restored) {
        showSnack(
          content: 'Subscription restored successfully!',
          status: SnackBarStatus.success,
        );
        authController.handleRouting();
        return;
      }

      showSnack(
        content: 'No active subscription found for this device.',
        status: SnackBarStatus.error,
      );
    } catch (_) {
      showSnack(
        content: 'Failed to restore subscription. Please try again.',
        status: SnackBarStatus.error,
      );
    } finally {
      _endAction();
    }
  }
}
