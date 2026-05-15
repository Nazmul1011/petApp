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
            // Top Heading & Sub-heading (Synced with Screen One)
            Obx(
              () => Text(
                controller.titleText,
                style: AppTypography.h5.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: R.height(12)),
            Text(
              "Tap. Speak. Hear them reply",
              style: AppTypography.bodySm.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),

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
            SizedBox(height: R.height(54.0)), // Updated to 54px bottom margin
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
                width: isListening ? R.width(220) : R.width(200),
                height: isListening ? R.width(220) : R.width(200),
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
                width: isListening ? R.width(160) : R.width(140),
                height: isListening ? R.width(160) : R.width(140),
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
                      : Icon(
                          Icons.mic,
                          size: R.width(50),
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
      ],
    );
  }

  Widget _buildResultState() {
    return AnimatedFadeIn(
      child: Column(
        children: [
          // Pet Head with Sound Waves (Aligned top-left)
          Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: R.width(260),
              height: R.height(180),
              child: Stack(
                children: [
                  // Pet Image (Using the new Wave versions)
                  Positioned(
                    left: 0,
                    top: R.height(20),
                    child: Image.asset(
                      controller.selectedPet.value == PetType.dog
                          ? 'assets/images/dogwave.png'
                          : 'assets/images/catwave.png',
                      width: R.width(260), // Increased width for the wave image
                      height: R.width(140),
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Animated Sound Waves (Commented out as per request)
                  /*
                  Positioned(
                    left: R.width(125),
                    top: R.height(60),
                    child: Obx(() {
                      final animValue = controller.soundWaveAnimation.value;
                      // Only show pulse if playing
                      return Opacity(
                        opacity: controller.isPlaying.value ? 1.0 : 0.0,
                        child: CustomPaint(
                          size: Size(R.width(60), R.width(60)),
                          painter: SoundWavePainter(
                            color: const Color(0xFFFFD700),
                            animationValue: animValue,
                          ),
                        ),
                      );
                    }),
                  ),
                  */
                ],
              ),
            ),
          ),

          SizedBox(height: R.height(10)),

          // Replay Button will be part of the morphing bar below
          SizedBox(height: R.height(24)),

          // Morphing Waveform Button
          Obx(() {
            final isPlaying = controller.isPlaying.value;
            return GestureDetector(
              onTap: () => controller.replayVoice(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                width: R.width(361),
                height: R.height(48),
                decoration: BoxDecoration(
                  color: isPlaying ? Colors.white : const Color(0xFFF7F4FF),
                  borderRadius: BorderRadius.circular(999), // Pill shape
                  border: Border.all(
                    color: AppColors.primaryColor.withValues(
                      alpha: isPlaying ? 0.1 : 1.0,
                    ),
                    width: 1.0,
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
                  child: isPlaying
                      ? Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: R.width(24),
                          ),
                          child: CustomPaint(
                            size: Size(double.infinity, R.height(24)),
                            painter: WaveformPainter(
                              values: controller.waveformValues.toList(),
                              color: AppColors.primaryColor,
                              secondaryColor: Colors.grey.withValues(
                                alpha: 0.1,
                              ),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.refresh,
                          color: AppColors.primaryColor,
                          size: R.width(28),
                        ),
                ),
              ),
            );
          }),
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
