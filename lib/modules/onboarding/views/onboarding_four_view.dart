import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_four_controller.dart';
import 'package:petapp/modules/onboarding/widgets/feature_card.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class OnboardingFourView extends GetView<OnboardingFourController> {
  const OnboardingFourView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<OnboardingFourController>()) {
      Get.put(OnboardingFourController());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.width(24)),
          child: Column(
            children: [
              SizedBox(height: R.height(60)),
              Text(
                "Your pet, your world",
                style: AppTypography.h4.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: R.height(12)),
              Text(
                "Decode barks. Interpret meows",
                style: AppTypography.bodyMd.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: R.height(48)),

              // Grid of features
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: R.width(16),
                  mainAxisSpacing: R.width(16),
                  childAspectRatio: 173 / 180,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    OnboardingFeatureCard(
                      icon: Image.asset(
                        "assets/images/onboarding_four/pet_profile.png",
                        width: R.width(32),
                        height: R.width(32),
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.image_rounded,
                          color: Color(0xFF7E57C2),
                          size: 28,
                        ),
                      ),
                      iconBgColor: const Color(0xFFF3E5F5),
                      title: "Pet profile",
                      subtitle: "Photo + personalized settings",
                    ),
                    OnboardingFeatureCard(
                      icon: Image.asset(
                        "assets/images/onboarding_four/saved_voices.png",
                        width: R.width(32),
                        height: R.width(32),
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.graphic_eq_rounded,
                          color: Color(0xFF43A047),
                          size: 28,
                        ),
                      ),
                      iconBgColor: const Color(0xFFE8F5E9),
                      title: "Saved voices",
                      subtitle: "Bookmark favorite moments",
                    ),
                    OnboardingFeatureCard(
                      icon: Image.asset(
                        "assets/images/onboarding_four/games_training.png",
                        width: R.width(32),
                        height: R.width(32),
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.sports_soccer_rounded,
                          color: Color(0xFFFB8C00),
                          size: 28,
                        ),
                      ),
                      iconBgColor: const Color(0xFFFFF3E0),
                      title: "Games & training",
                      subtitle: "Interactive activities",
                    ),
                    OnboardingFeatureCard(
                      icon: Image.asset(
                        "assets/images/onboarding_four/mood_history.png",
                        width: R.width(32),
                        height: R.width(32),
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.history_rounded,
                          color: Color(0xFFE53935),
                          size: 28,
                        ),
                      ),
                      iconBgColor: const Color(0xFFFFEBEE),
                      title: "Mood history",
                      subtitle: "Track emotional patterns",
                    ),
                  ],
                ),
              ),

              // Continue Button
              AppMaterialButton(
                label: "Continue",
                onPressed: () => controller.completeOnboarding(),
                borderRadius: 30,
                height: R.height(64),
                backgroundColor: AppColors.primaryColor,
                textColor: Colors.white,
              ),
              SizedBox(height: R.height(24)),

              // Home Indicator
              Container(
                width: R.width(134),
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: R.height(8)),
            ],
          ),
        ),
      ),
    );
  }
}
