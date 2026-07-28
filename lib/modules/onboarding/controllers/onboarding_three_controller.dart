import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/modules/auth/controllers/auth_controller.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:petapp/core/routes/app_routes.dart';

class EmotionData {
  final String title;
  final String description;
  final Color baseColor;
  final String dogImage;
  final String catImage;

  EmotionData({
    required this.title,
    required this.description,
    required this.baseColor,
    required this.dogImage,
    required this.catImage,
  });
}

class OnboardingThreeController extends GetxController {
  final Rx<PetType> selectedPet = PetType.none.obs;
  final RxInt currentPage = 0.obs;
  final PageController pageController = PageController();
  final AudioPlayer _player = AudioPlayer();

  // To track the scroll position for background color interpolation
  final RxDouble scrollOffset = 0.0.obs;

  final List<EmotionData> emotions = [
    EmotionData(
      title: "I'm hungry",
      description: "I need food or a treat right now",
      baseColor: const Color(0xFFFF9361), // Exact Deep Peach from screenshot
      dogImage: 'assets/images/onboarding_four/dog_hungry.webp',
      catImage: 'assets/images/onboarding_four/cat_hungry1.webp',
    ),
    EmotionData(
      title: "Let's play",
      description: "I have energy and want your attention",
      baseColor: const Color(0xFFA5D6A7), // Richer Green
      dogImage: 'assets/images/onboarding_four/dog_play.webp',
      catImage: 'assets/images/onboarding_four/cat_play1.webp',
    ),
    EmotionData(
      title: "I'm anxious",
      description: "Something feels off and I need comfort",
      baseColor: const Color(0xFFB39DDB), // Richer Purple
      dogImage: 'assets/images/onboarding_four/dog_sad.webp',
      catImage: 'assets/images/onboarding_four/cat_sad1.webp',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    selectedPet.value = Get.arguments as PetType? ?? PetType.dog;

    pageController.addListener(() {
      scrollOffset.value = pageController.page ?? 0.0;
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    _player.dispose();
    super.onClose();
  }

  void playPetSound() async {
    final sound = selectedPet.value == PetType.cat
        ? 'audio/meow_1.wav'
        : 'audio/bark_1.wav';

    try {
      await _player.stop();
      // Temporarily disabled sound on tab switch as requested
      // await _player.play(AssetSource(sound));
    } catch (e) {
      print('[Onboarding] Error playing sound: $e');
    }
  }

  Color getInterpolatedBackgroundColor() {
    final page = scrollOffset.value;
    final index = page.floor();
    final nextIndex = (index + 1).clamp(0, emotions.length - 1);
    final t = page - index;

    return Color.lerp(
          emotions[index].baseColor,
          emotions[nextIndex].baseColor,
          t,
        ) ??
        emotions[0].baseColor;
  }

  void completeOnboarding() {
    Get.toNamed(AppRoutes.onboardingFour);
  }
}
