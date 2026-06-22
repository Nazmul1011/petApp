import 'package:get/get.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../models/subscription_plan.dart';

class PaymentController extends GetxController with BaseController {
  final Rx<SubscriptionPlan> selectedPlan = SubscriptionPlan.yearlyRegular.obs;

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan.value = plan;
  }

  void handleButtonTap() {
    final subController = Get.find<SubscriptionModuleController>();
    subController.selectedPlan.value = selectedPlan.value;
    subController.continueSubscription(fromOnboarding: true);
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
