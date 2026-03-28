import 'package:get/get.dart';

import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/modules/payment/widgets/payment_required_modal.dart';

enum SubscriptionPlan { trial, weekly, monthly, yearly }

class PaymentController extends GetxController with BaseController {
  final Rx<SubscriptionPlan> selectedPlan = SubscriptionPlan.monthly.obs;

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan.value = plan;
  }

  void continueWithTrial() async {
    final result = await Get.dialog<bool>(
      const PaymentRequiredModal(),
      barrierDismissible: false,
    );

    if (result == true) {
      // User tapped Continue
      Get.log("User wants to continue with setting up a payment method.");
    } else {
      // User tapped Cancel
      Get.log("User cancelled payment method setup.");
    }
  }
}
