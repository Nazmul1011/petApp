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
    // Ensure we have fresh trial eligibility before choosing a path.
    await loadTrialAvailability();

    if (shouldStartFreeTrial) {
      await _startFreeTrial(fromOnboarding: fromOnboarding);
      return;
    }

    await _startPaidCheckout(fromOnboarding: fromOnboarding);
  }

  /// Used by the onboarding paywall close button: start trial when available,
  /// otherwise continue on the free tier (pet setup). Never silently no-ops.
  Future<void> dismissOnboardingPaywall() async {
    await loadTrialAvailability();

    if (trialAvailable.value) {
      selectedPlan.value = SubscriptionPlan.yearlyRegular;
      await _startFreeTrial(fromOnboarding: true);
      return;
    }

    Get.offNamed(AppRoutes.welcomeSplash);
  }

  Future<void> _startFreeTrial({required bool fromOnboarding}) async {
    final authController = AuthController.to;

    setLoading(true);
    final response = await _subscriptionService.startFreeTrial();

    if (!response.success) {
      setLoading(false);
      // Trial already used / active → fall through to paid checkout.
      final trialBlocked = response.statusCode == 409;
      if (trialBlocked) {
        trialAvailable.value = false;
        await _startPaidCheckout(fromOnboarding: fromOnboarding);
        return;
      }

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

    setLoading(true);
    final response = await _subscriptionService.createCheckoutSession(
      plan: selectedPlan.value.apiValue,
      successUrl: 'https://petapp.example.com/checkout/success',
      cancelUrl: 'https://petapp.example.com/checkout/cancel',
    );

    if (!response.success || response.data == null) {
      setLoading(false);
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
    setLoading(false);

    final result = await Get.to(
      () => PolarCheckoutWebView(
        checkoutUrl: checkoutUrl,
        successUrl: 'https://petapp.example.com/checkout/success',
        cancelUrl: 'https://petapp.example.com/checkout/cancel',
      ),
    );

    if (result == true && checkoutId != null) {
      setLoading(true);
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

      setLoading(false);
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
    final authController = AuthController.to;

    setLoading(true);
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
      setLoading(false);
    }
  }
}
