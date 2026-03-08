import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_two_controller.dart';
import 'package:petapp/modules/onboarding/widgets/waveform_widgets.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          children: [
            const SizedBox(height: 60), // Space from top
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

            // Bottom Button
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
                borderRadius: 30,
                height: 64,
                backgroundColor: isResult
                    ? AppColors.primaryColor
                    : Colors.white,
                textColor: isResult ? Colors.white : AppColors.primaryColor,
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMicState(VoiceState state) {
    final isListening = state == VoiceState.listening;
    final isProcessing = state == VoiceState.processing;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Status Bubble
        AnimatedOpacity(
          opacity: isProcessing ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Text(
              isListening ? "Listening.." : "Tap to speak",
              style: AppTypography.labelMd.copyWith(
                color: isListening ? AppColors.primaryColor : Colors.black,
              ),
            ),
          ),
        ),

        const SizedBox(height: 40),

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
                width: isListening ? 220 : 200,
                height: isListening ? 220 : 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening
                      ? AppColors.primaryColor.withValues(alpha: 0.05)
                      : Colors.transparent,
                  border: Border.all(
                    color: isListening
                        ? AppColors.primaryColor.withValues(alpha: 0.2)
                        : Colors.grey[100]!,
                    width: 1,
                  ),
                ),
              ),
              // Main Circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: isListening ? 160 : 140,
                height: isListening ? 160 : 140,
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
                      ? const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.mic,
                          size: 50,
                          color: isListening ? Colors.white : Colors.grey[400],
                        ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Waveform at bottom during listening
        AnimatedOpacity(
          opacity: isListening ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            width: 361,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomPaint(
                    size: const Size(double.infinity, 24),
                    painter: WaveformPainter(values: vals, color: dynamicColor),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildResultState() {
    return AnimatedFadeIn(
      child: Column(
        children: [
          // Pet Head with Sound Waves (Aligned top-left as per screenshot)
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 260,
              height: 180,
              child: Stack(
                children: [
                  // Pet Image
                  Positioned(
                    left: 0,
                    top: 20,
                    child: Image.asset(
                      controller.petImagePath,
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Animated Sound Waves (Golden Pulse)
                  Positioned(
                    left: 125,
                    top: 60,
                    child: Obx(() {
                      final animValue = controller.soundWaveAnimation.value;
                      return CustomPaint(
                        size: const Size(60, 60),
                        painter: SoundWavePainter(
                          color: const Color(0xFFFFD700), // Golden/Yellow
                          animationValue: animValue,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Waveform Container (Specific dimensions from user)
          Container(
            width: 361,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12), // radius-12
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.1),
                width: 1.0, // stroke-sm
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() {
                  // Explicit trigger
                  final vals = controller.waveformValues.toList();
                  return CustomPaint(
                    size: const Size(double.infinity, 24),
                    painter: WaveformPainter(
                      values: vals,
                      color: AppColors.primaryColor,
                      secondaryColor: Colors.grey.withValues(alpha: 0.2),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedFadeIn extends StatefulWidget {
  final Widget child;
  const AnimatedFadeIn({super.key, required this.child});

  @override
  State<AnimatedFadeIn> createState() => _AnimatedFadeInState();
}

class _AnimatedFadeInState extends State<AnimatedFadeIn>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
