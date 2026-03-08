import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardController());

    final isDog = controller.selectedPet.value == PetType.dog;
    final bgColor = isDog ? const Color(0xFFF3F1FF) : const Color(0xFFFFF1F1);

    return AppScaffold(
      horizontalPadding: 0,
      body: Container(
        width: double.infinity,
        color: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${controller.petName} Dashboard",
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Image.asset(
              isDog
                  ? 'assets/images/dog image.png'
                  : 'assets/images/cat image.png',
              width: 200,
            ),
            const SizedBox(height: 40),
            Text(
              "Welcome to your ${controller.petName.toLowerCase()}'s world!",
              style: AppTypography.bodyLg,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
