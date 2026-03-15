import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/core/routes/app_routes.dart';

class CreatePetProfileSplashController extends GetxController with BaseController {
  @override
  void onInit() {
    super.onInit();
    // Typical splash screen behavior: load resources, then navigate
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    await Future.delayed(const Duration(seconds: 3));
    Get.offAllNamed(AppRoutes.createPetProfile);
  }
}
