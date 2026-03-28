import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_controller.dart';

class DashboardController extends GetxController with BaseController {
  // Pet selection state
  final Rx<PetType> selectedPet = PetType.none.obs;

  // Talk Tab states (Microphone & Mode)
  final RxBool isRecording = false.obs;
  final RxBool isPetMode = true.obs;

  @override
  void onInit() {
    super.onInit();
    // defaulting for demo purposes if no args provided
    selectedPet.value = Get.arguments as PetType? ?? PetType.dog;
  }

  void toggleRecording() {
    isRecording.value = !isRecording.value;
  }

  void togglePetMode(bool value) {
    isPetMode.value = value;
  }

  String get petName => selectedPet.value == PetType.dog ? 'Dog' : 'Cat';
}
