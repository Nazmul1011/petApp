import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_two_controller.dart';
import 'package:petapp/modules/onboarding/widgets/waveform_widgets.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class OnboardingTwoView extends GetView<OnboardingTwoController> {
  const OnboardingTwoView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller if not already there
    if (!Get.isRegistered<OnboardingTwoController>()) {
      Get.put(OnboardingTwoController());
    }

    return AppScaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.width(2.0), // Updated to 10px
        ),
        child: Column(
          children: [
            SizedBox(height: R.height(80)), // Match top spacing
            // Main Interactive Area
            Expanded(
              child: Obx(() {
                final state = controller.voiceState.value;

                if (state == VoiceState.result) {
                  return _buildResultState();
                }

                return _buildMicState(state);
              }),
            ),

            // Bottom Button (Synced with Screen One)
            Obx(() {
              final state = controller.voiceState.value;
              final isResult = state == VoiceState.result;
              final isProcessing = state == VoiceState.processing;

              return AppMaterialButton(
                label: isResult ? "Continue" : "Skip demo",
                onPressed: isProcessing
                    ? null
                    : (isResult
                          ? () => controller.completeOnboarding()
                          : () => controller.skipDemo()),
              );
            }),
            SizedBox(height: R.height(20.0)), // Standard bottom gap
          ],
        ),
      ),
    );
  }

  Widget _buildMicState(VoiceState state) {
    final isListening = state == VoiceState.listening;
    final isProcessing = state == VoiceState.processing;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Top Heading & Sub-heading (Visible only during mic states)
        Obx(
          () => FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              controller.titleText,
              style: AppTypography.h4.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: R.height(12)),
        Text(
          "Tap. Speak. Hear them reply.",
          style: AppTypography.bodyMd.copyWith(
            color: Colors.grey[600],
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: R.height(128)),
        // Status Bubble
        AnimatedOpacity(
          opacity: isProcessing ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: R.width(20),
              vertical: R.height(10),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(R.width(25)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              isListening ? "LISTENING.." : "TAP TO SPEAK",
              style: AppTypography.labelMd.copyWith(
                color: isListening ? AppColors.primaryColor : Colors.black,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Mic Button
        GestureDetector(
          onLongPressStart: (_) => controller.startListening(),
          onLongPressEnd: (_) => controller.stopListening(),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Pulse Circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isListening ? R.width(180) : R.width(160),
                height: isListening ? R.width(180) : R.width(160),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening
                      ? AppColors.primaryColor.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: isListening
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
                  color: isListening ? AppColors.primaryColor : Colors.white,
                  boxShadow: [
                    if (!isListening)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 20,
                      ),
                  ],
                ),
                child: Center(
                  child: isProcessing
                      ? SizedBox(
                          width: R.width(40),
                          height: R.width(40),
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Image.asset(
                          'assets/images/onboarding_1/microphone.png',
                          width: R.width(50),
                          height: R.width(50),
                          fit: BoxFit.contain,
                          color: isListening
                              ? Colors.white
                              : AppColors.primaryColor,
                        ),
                ),
              ),
            ],
          ),
        ),

        // const SizedBox(height: 40),

        // Waveform at bottom during listening (Commented out as per request)
        /*
        AnimatedOpacity(
          opacity: isListening ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: R.width(361),
            height: R.height(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(R.width(12)),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Obx(() {
              final vals = controller.waveformValues.toList();
              // Dynamic color based on average intensity
              final avg = vals.isEmpty
                  ? 0.0
                  : vals.reduce((a, b) => a + b) / vals.length;
              final dynamicColor = Color.lerp(
                AppColors.primaryColor.withValues(alpha: 0.4),
                AppColors.primaryColor,
                (avg * 2).clamp(0.0, 1.0),
              )!;

              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: R.width(20)),
                  child: CustomPaint(
                    size: Size(double.infinity, R.height(24)),
                    painter: WaveformPainter(values: vals, color: dynamicColor),
                  ),
                ),
              );
            }),
          ),
        ),
        */
      ],
    );
  }

  Widget _buildResultState() {
    return Column(
      children: [
        // Pet Image (Using the new Wave versions from onboarding_1)
        Center(
          child: SizedBox(
            width: R.width(351),
            height: R.height(234),
            child: Image.asset(
              controller.selectedPet.value == PetType.dog
                  ? 'assets/images/onboarding_1/dog sound 1.png'
                  : 'assets/images/onboarding_1/Cat Sound 1.png',
              width: R.width(351),
              height: R.height(234),
              fit: BoxFit.contain,
            ),
          ),
        ),

        SizedBox(height: R.height(24)),

        // Morphing Waveform Button
        Obx(() {
          final isPlaying = controller.isPlaying.value;
          return GestureDetector(
            onTap: () => controller.replayVoice(),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: R.width(361),
                  height: R.height(48),
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? Colors.white
                        : AppColors.primaryColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999), // Pill shape
                    border: isPlaying
                        ? Border.all(
                            color: AppColors.primaryColor.withValues(
                              alpha: 0.1,
                            ),
                            width: 1.0,
                          )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isPlaying
                        ? Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: R.width(4),
                            ),
                            child: CustomPaint(
                              size: Size(double.infinity, R.height(24)),
                              painter: WaveformPainter(
                                values: controller.waveformValues.toList(),
                                color: AppColors.primaryColor,
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.refresh,
                                color: AppColors.primaryColor,
                                size: R.width(24),
                              ),
                              SizedBox(width: R.width(8)),
                              Text(
                                "Play again",
                                style: AppTypography.labelMd.copyWith(
                                  color: AppColors.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}
