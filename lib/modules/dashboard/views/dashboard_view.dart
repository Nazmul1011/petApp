import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/modules/auth/controllers/auth_controller.dart';
import 'package:petapp/modules/pet_profile/models/pet_model.dart' as pet;
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/app_header.dart';
import 'package:petapp/shared/widgets/dashboard_page_title.dart';
import 'package:petapp/shared/widgets/glass_container.dart';
import 'package:petapp/modules/onboarding/widgets/waveform_widgets.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/widgets/app_asset_image.dart';
import 'package:petapp/shared/widgets/pet_avatar/pet_avatar.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.white,
      horizontalPadding: 0,
      // Keep the existing custom SafeArea behavior (top: false).
      useSafeArea: false,
      body: SafeArea(
        top: false, // Handle top spacing manually for Figma accuracy
        child: Column(
          children: [
            const AppHeader(),
            const DashboardPageTitle(title: 'Talk'),
            Expanded(
              child: _buildInteractiveState(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveState() {
    return Column(
      children: [
        // Space to reach waveform position (approx 135 from top)
        SizedBox(height: R.height(135 - 80)), // Subtracting header height
        // Waveform Animation
        Obx(() => _buildTopAnimation()),

        // 40px gap as requested
        SizedBox(height: R.height(40)),

        _buildMicButton(),

        SizedBox(height: R.height(20)),

        // Mode Toggle
        Obx(() {
          final isIdle = controller.uiState.value == TranslationUIState.idle;
          return AnimatedOpacity(
            opacity: isIdle ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IgnorePointer(ignoring: !isIdle, child: _buildModeToggle()),
          );
        }),

        const Spacer(),
      ],
    );
  }

  Widget _buildMicButton() {
    return Obx(() {
      final isRecording =
          controller.uiState.value == TranslationUIState.recording;

      return Center(
        child: Listener(
          onPointerDown: (_) => controller.startRecording(),
          onPointerUp: (_) => controller.stopRecording(),
          onPointerMove: (event) {
            const double glassSize = 200.0;
            if (event.localPosition.dx < 0 ||
                event.localPosition.dx > R.width(glassSize) ||
                event.localPosition.dy < 0 ||
                event.localPosition.dy > R.height(glassSize)) {
              controller.stopRecording();
            }
          },
          child: GlassContainer(
            width: R.width(200),
            height: R.width(200),
            borderRadius: 100,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Pulse Circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: isRecording ? R.width(180) : R.width(160),
                    height: isRecording ? R.width(180) : R.width(160),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording
                          ? AppColors.primaryColor.withValues(alpha: 0.15)
                          : Colors.transparent,
                      border: isRecording
                          ? Border.all(
                              color: AppColors.primaryColor.withValues(
                                alpha: 0.2,
                              ),
                              width: 1,
                            )
                          : null,
                    ),
                  ),
                  // Main Circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: R.width(160),
                    height: R.width(160),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording ? AppColors.primaryColor : Colors.white,
                      boxShadow: [
                        if (!isRecording)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 20,
                          ),
                      ],
                    ),
                    child: Center(
                      child: AppAssetImage(
                        'assets/images/onboarding_1/microphone.png',
                        width: R.width(50),
                        height: R.width(50),
                        fit: BoxFit.contain,
                        color: isRecording
                            ? Colors.white
                            : AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTopAnimation() {
    final isRecording =
        controller.uiState.value == TranslationUIState.recording;
    return AnimatedOpacity(
      opacity: isRecording ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Center(
        child: GlassContainer(
          width: R.width(361),
          height: R.height(48),
          borderRadius: 16,
          child: Center(
            child: CustomPaint(
              size: Size(R.width(361), R.height(48)),
              painter: WaveformPainter(
                values: controller.waveformValues.toList(),
                color: const Color(0xFF6C3BAA),
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildModeToggle() {
    return GestureDetector(
      onTap: controller.toggleMode,
      child: GlassContainer(
        width: R.width(192),
        height: R.height(66),
        borderRadius: 33,
        padding: EdgeInsets.symmetric(
          horizontal: R.width(8),
        ),
        child: Obx(
          () {
            // Rebuild when active pet / uploaded image changes.
            final _ = AuthController.to.user.value;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildToggleAvatar(isHuman: controller.isHumanToDog.value),
                AnimatedRotation(
                  turns: controller.isHumanToDog.value ? 0.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: const Icon(
                    Icons.swap_horiz,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
                _buildToggleAvatar(isHuman: !controller.isHumanToDog.value),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildToggleAvatar({required bool isHuman}) {
    final outerSize = R.width(50);
    // Keep a clear white ring around the inner image (like the human emoji).
    final innerSize = R.width(32);

    return Container(
      width: outerSize,
      height: outerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
          width: 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: isHuman
          ? AppAssetImage(
              'assets/images/Emoji Image.png',
              width: innerSize,
              height: innerSize,
              fit: BoxFit.contain,
            )
          : SizedBox(
              width: innerSize,
              height: innerSize,
              child: PetAvatar(
                // Uploaded pet photo when available; otherwise nicer dog/cat asset.
                imageUrl: controller.activePetImageUrl,
                type: controller.selectedPet.value == PetType.dog
                    ? pet.PetType.DOG
                    : pet.PetType.CAT,
                size: innerSize,
                fit: BoxFit.cover,
              ),
            ),
    );
  }
}
