import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          padding: EdgeInsets.symmetric(horizontal: R.width(10.0)),
          child: Column(
            children: [
              SizedBox(height: R.height(80)), // Match top spacing
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Your pet, your world",
                  style: AppTypography.h4.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: R.height(12)),
              Text(
                "Decode barks. Interpret meows.",
                style: AppTypography.bodyMd.copyWith(
                  color: Colors.grey[600],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: R.height(48)),

              // Grid of features
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: R.width(12),
                  mainAxisSpacing: R.width(12),
                  childAspectRatio: 173 / 180, // Match 180 height for a taller card layout
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    OnboardingFeatureCard(
                      icon: Image.asset(
                        "assets/images/onbarding-4/picture.png",
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.image_rounded,
                          color: Color(0xFF7E57C2),
                          size: 28,
                        ),
                      ),
                      iconBgColor: const Color(0xFFF2ECFA),
                      title: "Pet profile",
                      subtitle: "Photo + personalized settings",
                      autoPlayDelay: const Duration(milliseconds: 500),
                    ),
                    OnboardingFeatureCard(
                      icon: Image.asset(
                        "assets/images/onbarding-4/voice.png",
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.graphic_eq_rounded,
                          color: Color(0xFF43A047),
                          size: 28,
                        ),
                      ),
                      iconBgColor: const Color(0xFFE5F6EE),
                      title: "Saved voices",
                      subtitle: "Bookmark moments",
                      autoPlayDelay: const Duration(milliseconds: 2300),
                    ),
                    OnboardingFeatureCard(
                      icon: Image.asset(
                        "assets/images/onbarding-4/training.png",
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.sports_soccer_rounded,
                          color: Color(0xFFFB8C00),
                          size: 28,
                        ),
                      ),
                      iconBgColor: const Color(0xFFFFF0E5),
                      title: "Games & training",
                      subtitle: "Interactive activities",
                      autoPlayDelay: const Duration(milliseconds: 4100),
                    ),
                    OnboardingFeatureCard(
                      icon: Image.asset(
                        "assets/images/onbarding-4/love.png",
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.history_rounded,
                          color: Color(0xFFE53935),
                          size: 28,
                        ),
                      ),
                      iconBgColor: const Color(0xFFFFF0F2),
                      title: "Mood history",
                      subtitle: "Track patterns",
                      autoPlayDelay: const Duration(milliseconds: 5900),
                    ),
                  ],
                ),
              ),

              // Continue Button (Synced with Global Spec)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.width(6.0)),
                child: AppMaterialButton(
                  label: "Get started",
                  onPressed: () => controller.completeOnboarding(),
                ),
              ),
              SizedBox(height: R.height(20.0)), // Standard bottom gap
            ],
          ),
        ),
      ),
    );
  }
}
