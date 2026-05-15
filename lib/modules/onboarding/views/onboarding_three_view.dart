import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:petapp/core/routes/app_routes.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_three_controller.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/helpers/responsive.dart';

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
                    colors: [Colors.white, backgroundColor],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: R.width(10.0)),
                child: Column(
                  children: [
                    SizedBox(height: R.height(80)), // Match top spacing
                    Text(
                      "Understand feelings",
                      style: AppTypography.h5.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: R.height(12)), // Match 12px gap
                    Text(
                      "Swipe to explore",
                      style: AppTypography.bodySm.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(),

                    // Swipeable Cards (With smooth scaling)
                    SizedBox(
                      height: R.height(440),
                      child: PageView.builder(
                        controller: controller.pageController,
                        itemCount: controller.emotions.length,
                        onPageChanged: (index) {
                          controller.currentPage.value = index;
                          controller.playPetSound();
                        },
                        itemBuilder: (context, index) {
                          return AnimatedBuilder(
                            animation: controller.pageController,
                            builder: (context, child) {
                              double value = 1.0;
                              if (controller
                                  .pageController
                                  .position
                                  .hasContentDimensions) {
                                value =
                                    (controller.pageController.page! - index)
                                        .abs();
                                value = (1 - (value * 0.15)).clamp(0.85, 1.0);
                              } else if (index != 0) {
                                value =
                                    0.85; // Initial scale for non-first cards
                              }
                              return Transform.scale(
                                scale: value,
                                child: _buildEmotionCard(context, index),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    // Page Indicator
                    SizedBox(height: R.height(32)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.emotions.length,
                        (index) => Container(
                          margin: EdgeInsets.symmetric(horizontal: R.width(4)),
                          width: R.width(8),
                          height: R.width(8),
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

                    // Continue Button (Custom White design for Screen Three)
                    Obx(() {
                      final isLastPage = controller.currentPage.value == controller.emotions.length - 1;
                      return AnimatedScale(
                        scale: isLastPage ? 1.0 : 0.8,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutBack,
                        child: AnimatedOpacity(
                          opacity: isLastPage ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 300),
                          child: IgnorePointer(
                            ignoring: !isLastPage,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: R.width(6.0)), // Add 6px to the 10px screen padding to make 16px total
                              child: AppMaterialButton(
                                label: "Continue",
                                backgroundColor: Colors.white,
                                textColor: Colors.black,
                                onPressed: () => Get.toNamed(AppRoutes.onboardingFour),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: R.height(54.0)), // Match 54px bottom margin
                  ],
                ),
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
    final backgroundColor = controller.getInterpolatedBackgroundColor();

    return Center(
      child: Container(
        // Outer Layer: The Light Thick Border
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(R.width(44)),
        ),
        padding: EdgeInsets.all(R.width(12)),
        child: Container(
          // Inner Layer: The Deep Thick Border
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(R.width(36)),
          ),
          padding: EdgeInsets.all(R.width(12)),
          child: Container(
            // Core Layer: The White Card
            width: R.width(273),
            height: R.height(340),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(R.width(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 32),
                // Emotion Specific Illustration (273 x 340)
                Expanded(
                  child: Image.asset(
                    petImage,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  emotion.title,
                  style: AppTypography.h5.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: R.height(8)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: R.width(24)),
                  child: Text(
                    emotion.description,
                    style: AppTypography.bodySm.copyWith(
                      color: Colors.black.withValues(alpha: 0.6),
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
