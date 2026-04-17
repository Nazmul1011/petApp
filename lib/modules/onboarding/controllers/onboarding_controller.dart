import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/modules/onboarding/widgets/pet_pop_overlay.dart';

enum PetType { none, dog, cat }

class OnboardingController extends GetxController with BaseController {
  final Rx<PetType> selectedPet = PetType.none.obs;
  final AudioPlayer _player = AudioPlayer();

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

  void _playPetSound() async {
    final pet = selectedPet.value;
    final sound = pet == PetType.cat ? 'audio/meow_1.wav' : 'audio/bark_1.wav';
    try {
      await _player.stop();
      await _player.play(AssetSource(sound));
    } catch (e) {
      Get.log("[Onboarding Step 1] Error playing sound: $e");
    }
  }

  @override
  void onClose() {
    _player.dispose();
    super.onClose();
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
