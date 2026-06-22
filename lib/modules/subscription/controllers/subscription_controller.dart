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

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan.value = plan;
  }

  Future<void> continueSubscription({bool fromOnboarding = false}) async {
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
        content: response.message ?? 'Failed to initialize checkout',
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
        if (fromOnboarding) {
          Get.offNamed(AppRoutes.welcomeSplash);
        } else {
          Get.back();
        }
      } else {
        showSnack(
          content: 'Failed to validate subscription. Please contact support.',
          status: SnackBarStatus.error,
        );
      }
      setLoading(false);
    } else if (result == false) {
      showSnack(
        content: 'Checkout cancelled.',
        status: SnackBarStatus.error,
      );
    }
  }

  void restorePurchase() {
    // Logic for restoring purchase
  }
}
