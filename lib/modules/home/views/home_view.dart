import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final onboardingController = Get.find<OnboardingController>();
    final isDog = onboardingController.selectedPet.value == PetType.dog;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.width(20), vertical: R.height(10)),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/Logo_image.png',
                    height: R.height(32),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF4E5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.workspace_premium, color: Colors.orange, size: R.width(20)),
                  ),
                  SizedBox(width: R.width(12)),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: R.width(8), vertical: R.height(4)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          isDog ? 'assets/images/dog image.png' : 'assets/images/cat image.png',
                          width: R.width(24),
                          height: R.width(24),
                        ),
                        const Icon(Icons.arrow_drop_down, color: Colors.black54),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Center(
              child: Container(
                width: R.width(180),
                height: R.width(180),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade100, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.mic,
                  size: R.width(60),
                  color: Colors.grey.shade400,
                ),
              ),
            ),
            SizedBox(height: R.height(40)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: R.width(16), vertical: R.height(8)),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4A4A4A),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: Colors.white, size: R.width(16)),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: R.width(16)),
                    child: Icon(Icons.swap_horiz, color: AppColors.primaryColor, size: R.width(20)),
                  ),
                  Image.asset(
                    isDog ? 'assets/images/dog image.png' : 'assets/images/cat image.png',
                    width: R.width(28),
                    height: R.width(28),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }
}
