import 'package:get/get.dart';
import 'package:petapp/modules/payment/controllers/payment_controller.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:petapp/modules/payment/services/payment_service.dart';
import 'package:petapp/modules/profile/controllers/profile_controller.dart';
import 'package:petapp/modules/main/controllers/main_navigation_controller.dart';

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentService>(() => PaymentService(), fenix: true);
    Get.lazyPut<PaymentController>(() => PaymentController(), fenix: true);
    Get.lazyPut<OnboardingController>(() => OnboardingController(), fenix: true);
    Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    Get.lazyPut<MainNavigationController>(() => MainNavigationController(), fenix: true);
  }
}
