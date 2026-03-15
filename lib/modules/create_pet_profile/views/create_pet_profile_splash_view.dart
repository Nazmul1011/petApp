import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/spacer/app_spacer.dart';

import '../controllers/create_pet_profile_splash_controller.dart';

class CreatePetProfileSplashView extends GetView<CreatePetProfileSplashController> {
  const CreatePetProfileSplashView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<CreatePetProfileSplashController>()) {
      Get.put(CreatePetProfileSplashController());
    }

    return AppScaffold(
      horizontalPadding: 0,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF7F67CB), // var(--Surface-surface-btn-primary)
        child: Column(
          children: [
            const Spacer(),
            
            // Logo Container
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo Image
                Image.asset(
                  'assets/images/Logo Image.png',
                  width: R.width(150),
                  height: R.height(100),
                  fit: BoxFit.contain, // Based on URL CSS with "contain/cover" type scaling
                ),
                
                addSpacer(R.height(32)), // Gap: var(--Spacing-spacing-32, 32px)
                
                // Welcome to text
                Text(
                  "Welcome to",
                  style: AppTypography.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                // PawLingo text
                Text(
                  "PawLingo",
                  style: AppTypography.h4.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            
            const Spacer(),
            
            // Paws Indicator Container
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPawIcon(opacity: 1.0),
                addSpacer(R.width(4), direction: SpacerDirection.horizontal),
                _buildPawIcon(opacity: 1.0),
                addSpacer(R.width(4), direction: SpacerDirection.horizontal),
                _buildPawIcon(opacity: 1.0),
                addSpacer(R.width(4), direction: SpacerDirection.horizontal),
                _buildPawIcon(opacity: 0.5),
                addSpacer(R.width(4), direction: SpacerDirection.horizontal),
                _buildPawIcon(opacity: 0.5),
              ],
            ),
            
            addSpacer(R.height(40)), // Space 40 below paws
          ],
        ),
      ),
    );
  }

  Widget _buildPawIcon({required double opacity}) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        'assets/images/pets.png', // pet paw image from provided path
        width: R.width(20),
        height: R.height(20),
        fit: BoxFit.contain,
      ),
    );
  }
}
