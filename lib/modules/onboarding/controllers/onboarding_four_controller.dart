import 'package:get/get.dart';
import 'package:petapp/modules/auth/controllers/auth_controller.dart';

class OnboardingFourController extends GetxController {
  void completeOnboarding() {
    AuthController.to.completeOnboarding();
  }
}
