import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_controller.dart';

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

  // To track the scroll position for background color interpolation
  final RxDouble scrollOffset = 0.0.obs;

  final List<EmotionData> emotions = [
    EmotionData(
      title: "I'm hungry",
      description: "I need food or a treat right now",
      baseColor: const Color(0xFFFFCCBC), // Peach
      dogImage: 'assets/images/hungry dog 1.png',
      catImage: 'assets/images/hungry cat 1.png',
    ),
    EmotionData(
      title: "Let's play",
      description: "I have energy and want your attention",
      baseColor: const Color(0xFFC8E6C9), // Light Green
      dogImage: 'assets/images/play dog 1.png',
      catImage: 'assets/images/play cat 1.png',
    ),
    EmotionData(
      title: "I'm anxious",
      description: "Something feels off and I need comfort",
      baseColor: const Color(0xFFD1C4E9), // Light Purple
      dogImage: 'assets/images/anxious dog 1.png',
      catImage: 'assets/images/anixious image cat.png',
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
    super.onClose();
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
    Get.offAllNamed(AppRoutes.dashboard, arguments: selectedPet.value);
  }
}
