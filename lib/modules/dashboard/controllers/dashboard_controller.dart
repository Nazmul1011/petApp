import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_controller.dart';

class DashboardController extends GetxController with BaseController {
  final Rx<PetType> selectedPet = PetType.none.obs;

  @override
  void onInit() {
    super.onInit();
    // In a real app, we'd persist this, but for now we can pass it via arguments or a service
    // Defaulting to dog if none passed for demo safety
    selectedPet.value = Get.arguments as PetType? ?? PetType.dog;
  }

  String get petName => selectedPet.value == PetType.dog ? 'Dog' : 'Cat';
}
