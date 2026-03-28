import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/modules/payment/controllers/payment_controller.dart'; // To reuse SubscriptionPlan

class SubscriptionModuleController extends GetxController with BaseController {
  final Rx<SubscriptionPlan> selectedPlan = SubscriptionPlan.monthly.obs;
  final RxBool isLoading = false.obs;

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan.value = plan;
  }

  void continueSubscription() {
    Get.log('User tapped continue for plan: ${selectedPlan.value}');
    // Add logic for processing the subscription toggle
  }
}
