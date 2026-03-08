import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_three_controller.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';

class OnboardingThreeView extends GetView<OnboardingThreeController> {
  const OnboardingThreeView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OnboardingThreeController>()) {
      Get.put(OnboardingThreeController());
    }

    return Obx(() {
      final backgroundColor = controller.getInterpolatedBackgroundColor();

      return Scaffold(
        body: Stack(
          children: [
            // Background Gradient shifting
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      backgroundColor.withValues(alpha: 0.2),
                      backgroundColor.withValues(alpha: 0.5),
                      backgroundColor,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 48),
                  Text(
                    "Understand feelings",
                    style: AppTypography.h4.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Swipe to explore",
                    style: AppTypography.bodyMd.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(),

                  // Swipeable Cards
                  SizedBox(
                    height: 440,
                    child: PageView.builder(
                      controller: controller.pageController,
                      itemCount: controller.emotions.length,
                      onPageChanged: (index) =>
                          controller.currentPage.value = index,
                      itemBuilder: (context, index) {
                        return _buildEmotionCard(context, index);
                      },
                    ),
                  ),

                  // Page Indicator
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      controller.emotions.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: controller.currentPage.value == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Continue Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: AnimatedOpacity(
                      opacity:
                          controller.currentPage.value ==
                              controller.emotions.length - 1
                          ? 1.0
                          : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: IgnorePointer(
                        ignoring:
                            controller.currentPage.value !=
                            controller.emotions.length - 1,
                        child: AppMaterialButton(
                          label: "Continue",
                          onPressed: () => controller.completeOnboarding(),
                          borderRadius: 30,
                          height: 64,
                          backgroundColor: Colors.white,
                          textColor: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEmotionCard(BuildContext context, int index) {
    final emotion = controller.emotions[index];
    final petType = controller.selectedPet.value;
    final isDog = petType.name == 'dog';
    final petImage = isDog ? emotion.dogImage : emotion.catImage;
    final isSvg = petImage.endsWith('.svg');

    return Center(
      child: Container(
        width: 311,
        height: 420,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 48),
            // Emotion Specific Illustration
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: isSvg
                    ? SvgPicture.asset(petImage, fit: BoxFit.contain)
                    : Image.asset(petImage, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emotion.title,
              style: AppTypography.h5.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                emotion.description,
                style: AppTypography.bodyMd.copyWith(
                  color: Colors.black54,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}
