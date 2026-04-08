import 'package:get/get.dart';
import 'package:petapp/core/routes/app_routes.dart';

import 'package:petapp/core/controllers/base_controller.dart';

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
}
