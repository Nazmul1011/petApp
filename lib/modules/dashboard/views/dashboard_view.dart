import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/app_header.dart';
import 'package:petapp/modules/onboarding/widgets/waveform_widgets.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false, // Handle top spacing manually for Figma accuracy
        child: Column(
          children: [
            const AppHeader(),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: R.width(24),
                  vertical: R.height(8),
                ),
                child: Text(
                  "Talk",
                  style: AppTypography.h5.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
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
            final double limit = isRecording ? 180.0 : 160.0;
            if (event.localPosition.dx < 0 ||
                event.localPosition.dx > R.width(limit) ||
                event.localPosition.dy < 0 ||
                event.localPosition.dy > R.height(limit)) {
              controller.stopRecording();
            }
          },
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
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
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
                  child: Image.asset(
                    'assets/images/onboarding_1/microphone.png',
                    width: R.width(50),
                    height: R.width(50),
                    fit: BoxFit.contain,
                    color: isRecording ? Colors.white : AppColors.primaryColor,
                  ),
                ),
              ),
            ],
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
        child: Container(
          width: R.width(361),
          height: R.height(48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
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
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.width(16),
          vertical: R.height(12),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Obx(
          () => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildToggleAvatar(isHuman: controller.isHumanToDog.value),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: R.width(16)),
                child: const Icon(
                  Icons.swap_horiz,
                  color: Color(0xFF6C3BAA),
                  size: 20,
                ),
              ),
              _buildToggleAvatar(isHuman: !controller.isHumanToDog.value),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleAvatar({required bool isHuman}) {
    if (isHuman) {
      return Container(
        width: R.width(28),
        height: R.width(28),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade700,
        ),
        child: const Icon(Icons.person, color: Colors.white, size: 18),
      );
    } else {
      return Image.asset(
        controller.selectedPet.value == PetType.dog
            ? 'assets/images/dogwave.png'
            : 'assets/images/catwave.png',
        width: R.width(28),
        height: R.width(28),
        fit: BoxFit.contain,
      );
    }
  }
}
