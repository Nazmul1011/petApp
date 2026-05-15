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
          padding: EdgeInsets.symmetric(horizontal: R.width(10.0)),
          child: Column(
            children: [
              SizedBox(height: R.height(80)), // Match top spacing
              Text(
                "Your pet, your world",
                style: AppTypography.h5.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: R.height(12)),
              Text(
                "Decode barks. Interpret meows",
                style: AppTypography.bodySm.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: R.height(48)),

              // Grid of features
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: R.width(12),
                  mainAxisSpacing: R.width(12),
                  childAspectRatio: 173 / 158, // Match 158 height
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    OnboardingFeatureCard(
                      icon: Image.asset(
                        "assets/images/onbarding-4/first.png",
                        fit: BoxFit.fill,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.image_rounded,
                          color: Color(0xFF7E57C2),
                          size: 28,
                        ),
                      ),
                      iconBgColor: const Color(0xFFF7F4FF),
                      title: "Pet profile",
                      subtitle: "Photo + settings",
                    ),
                    OnboardingFeatureCard(
                      icon: Image.asset(
                        "assets/images/onbarding-4/second.png",
                        fit: BoxFit.fill,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.graphic_eq_rounded,
                          color: Color(0xFF43A047),
                          size: 28,
                        ),
                      ),
                      iconBgColor: const Color(0xFFE8F5E9),
                      title: "Saved voices",
                      subtitle: "Bookmark moments",
                    ),
                    OnboardingFeatureCard(
                      icon: Image.asset(
                        "assets/images/onbarding-4/third.png",
                        fit: BoxFit.fill,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.sports_soccer_rounded,
                          color: Color(0xFFFB8C00),
                          size: 28,
                        ),
                      ),
                      iconBgColor: const Color(0xFFFFF3E0),
                      title: "Games & training",
                      subtitle: "Play together",
                    ),
                    OnboardingFeatureCard(
                      icon: Image.asset(
                        "assets/images/onbarding-4/four.png",
                        fit: BoxFit.fill,
                        errorBuilder: (c, e, s) => const Icon(
                          Icons.history_rounded,
                          color: Color(0xFFE53935),
                          size: 28,
                        ),
                      ),
                      iconBgColor: const Color(0xFFFFEBEE),
                      title: "Mood history",
                      subtitle: "Track patterns",
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
              SizedBox(height: R.height(54.0)), // Match 54px bottom margin
            ],
          ),
        ),
      ),
    );
  }
}
