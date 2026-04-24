import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/modules/payment/controllers/payment_controller.dart';
import 'package:petapp/modules/auth/controllers/auth_controller.dart';
import 'package:petapp/shared/widgets/snack_bar/app_snack_bar.dart';

import '../services/subscription_service.dart';
import '../views/polar_checkout_webview.dart';

class SubscriptionModuleController extends GetxController with BaseController {
  final SubscriptionService _subscriptionService = SubscriptionService();
  final Rx<SubscriptionPlan> selectedPlan = SubscriptionPlan.monthly.obs;

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan.value = plan;
  }

  Future<void> continueSubscription() async {
    final authController = AuthController.to;
    final planName = selectedPlan.value
        .toString()
        .split('.')
        .last
        .toUpperCase();

    setLoading(true);
    final response = await _subscriptionService.createCheckoutSession(
      plan: planName,
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

    // Open Webview
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
        Get.back(); // Return to previous screen
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
        status: SnackBarStatus.error, // or warning if available
      );
    }
  }
}
