import 'package:get/get.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';

enum SubscriptionPlan { trial, weekly, monthly, yearly }

class PaymentController extends GetxController with BaseController {
  final Rx<SubscriptionPlan> selectedPlan = SubscriptionPlan.monthly.obs;

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan.value = plan;
  }

  void continueWithTrial() async {
    // Backend for payment is not fully completed.
    // Proceed directly to the Pet Profile setup via Welcome Splash.
    Get.offNamed(AppRoutes.welcomeSplash);
  }

  void handleButtonTap() {
    if (selectedPlan.value == SubscriptionPlan.trial) {
      continueWithTrial();
    } else {
      final subController = Get.find<SubscriptionModuleController>();
      subController.selectedPlan.value = selectedPlan.value;
      subController.continueSubscription();
    }
  }

  void openPrivacyPolicy() {
    Get.toNamed(AppRoutes.legal, arguments: {'tab': 0});
  }

  void openTermsConditions() {
    Get.toNamed(AppRoutes.legal, arguments: {'tab': 1});
  }

  void restorePurchase() {
    // Logic for restoring purchase
  }
}
