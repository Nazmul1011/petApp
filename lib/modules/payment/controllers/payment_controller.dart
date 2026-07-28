import 'package:get/get.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import '../../subscription/controllers/subscription_controller.dart';
import '../models/subscription_plan.dart';

class PaymentController extends GetxController with BaseController {
  final Rx<SubscriptionPlan> selectedPlan = SubscriptionPlan.yearlyRegular.obs;

  @override
  void onInit() {
    super.onInit();
    // Refresh trial availability each time payment is opened.
    if (Get.isRegistered<SubscriptionModuleController>()) {
      Get.find<SubscriptionModuleController>().loadTrialAvailability();
    }
  }

  void selectPlan(SubscriptionPlan plan) {
    selectedPlan.value = plan;
  }

  void handleButtonTap() {
    final subController = Get.find<SubscriptionModuleController>();
    // Ignore extra taps while Continue / close is already running.
    if (subController.isLoading.value) return;
    subController.selectedPlan.value = selectedPlan.value;
    subController.continueSubscription(fromOnboarding: true);
  }

  /// Close / cancel on the onboarding paywall.
  /// If trial already active → just close. If trial available → start once.
  /// Otherwise continue on the free tier into pet setup.
  Future<void> dismissPaywall() async {
    final subController = Get.find<SubscriptionModuleController>();
    if (subController.isLoading.value) return;
    await subController.dismissOnboardingPaywall();
  }

  void openPrivacyPolicy() {
    Get.toNamed(AppRoutes.legal, arguments: {'tab': 0});
  }

  void openTermsConditions() {
    Get.toNamed(AppRoutes.legal, arguments: {'tab': 1});
  }

  Future<void> restorePurchase() async {
    final subController = Get.find<SubscriptionModuleController>();
    await subController.restorePurchase();
  }
}
