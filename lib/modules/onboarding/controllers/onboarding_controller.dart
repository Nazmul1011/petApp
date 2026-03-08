import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/modules/onboarding/widgets/pet_pop_overlay.dart';

enum PetType { none, dog, cat }

class OnboardingController extends GetxController with BaseController {
  final Rx<PetType> selectedPet = PetType.none.obs;

  void selectPet(PetType type) {
    selectedPet.value = type;
    HapticFeedback.lightImpact();
    _playPetSound();
    _showPopAnimation(type);
  }

  void _showPopAnimation(PetType type) {
    final imagePath = type == PetType.dog
        ? 'assets/images/dog image.png'
        : 'assets/images/cat image.png';

    Get.dialog(
      PetPopOverlay(imagePath: imagePath, onFinish: () => Get.back()),
      barrierColor: Colors.black.withValues(alpha: 0.2),
      useSafeArea: true,
    );
  }

  void _playPetSound() {
    // Placeholder for actual dog/cat sounds
    // User can add dog.mp3 and cat.mp3 to assets and use a player here
    SystemSound.play(SystemSoundType.click);
    Get.log('Playing pet sound preview...');
  }

  void completeOnboarding() {
    if (selectedPet.value == PetType.none) {
      return;
    }

    // Navigate to second onboarding screen with selection
    Get.toNamed(AppRoutes.onboardingTwo, arguments: selectedPet.value);
  }

  String get buttonText {
    if (selectedPet.value == PetType.none) {
      return "Let's talk";
    }
    final petName = selectedPet.value == PetType.dog ? 'dog' : 'cat';
    return "Let's talk to your $petName";
  }

  bool get isPetSelected => selectedPet.value != PetType.none;
}
