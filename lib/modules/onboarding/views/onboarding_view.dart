import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:petapp/modules/onboarding/widgets/pet_card.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller
    Get.put(OnboardingController());

    return AppScaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.width(2.0), // 16px Side Margins
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: R.height(80)), // Adjusted top spacing
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "Choose your companion",
                style: AppTypography.h4.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: R.height(12)),
            Text(
              "We'll personalize sounds, translations,\nand interactions for them.",
              style: AppTypography.bodyMd.copyWith(
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  PetCard(
                    type: PetType.dog,
                    label: "Woof",
                    imagePath: 'assets/images/onboarding_1/dog face 1.png',
                    isSelected: controller.selectedPet.value == PetType.dog,
                    onTap: () => controller.selectPet(PetType.dog),
                  ),
                  PetCard(
                    type: PetType.cat,
                    label: "Meow",
                    imagePath: 'assets/images/onboarding_1/cat face 1.png',
                    isSelected: controller.selectedPet.value == PetType.cat,
                    onTap: () => controller.selectPet(PetType.cat),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            Obx(
              () => AppMaterialButton(
                label: controller.buttonText,
                onPressed: controller.selectedPet.value != PetType.none
                    ? () => controller.completeOnboarding()
                    : null,
              ),
            ),
            SizedBox(height: R.height(20.0)), // Standard bottom gap
          ],
        ),
      ),
    );
  }
}
