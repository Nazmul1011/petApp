import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/modules/onboarding/widgets/waveform_widgets.dart';
import 'package:petapp/modules/dashboard/controllers/dashboard_controller.dart';

class TalkResultView extends GetView<DashboardController> {
  const TalkResultView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            controller.reset();
          }
        },
        child: SafeArea(
          top: true,
          child: Column(
            children: [
              // const AppHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: R.width(24)),
                child: Column(
                  children: [
                    SizedBox(height: R.height(40)),

                    // Large Pet Image (only for Human-to-Pet)
                    _buildPetWithWaves(),

                    Obx(
                      () => SizedBox(
                        height: controller.isHumanToDog.value
                            ? R.height(20)
                            : 0,
                      ),
                    ),

                    // Translation Result Text (Pet to Human)
                    Obx(() {
                      if (controller.isHumanToDog.value)
                        return const SizedBox.shrink();
                      return Column(
                        children: [
                          if (controller.detectedFrequency.value > 0)
                            Padding(
                              padding: EdgeInsets.only(bottom: R.height(8)),
                              child: Text(
                                "${controller.detectedFrequency.value.toStringAsFixed(0)} Hz",
                                style: AppTypography.labelXs.copyWith(
                                  color: const Color(0xFF6C3BAA),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Text(
                            controller.resultText.value.isEmpty
                                ? "No ${controller.selectedPet.value == PetType.dog ? 'Dog' : 'Cat'} sound detected"
                                : controller.resultText.value,
                            style: AppTypography.h4.copyWith(
                              fontWeight: FontWeight.w700,
                              color: controller.resultText.value.isEmpty
                                  ? Colors.grey
                                  : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: R.height(20)),
                        ],
                      );
                    }),

                    // Boxed Waveform
                    _buildBoxedWaveform(),

                    SizedBox(height: R.height(30)),

                    // Playback Controls
                    _buildResultIcons(),

                    SizedBox(height: R.height(20)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.width(24)),
              child: _buildSaveVoiceSection(),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildPetWithWaves() {
    return Obx(() {
      if (!controller.isHumanToDog.value) return const SizedBox.shrink();
      final isDog = controller.selectedPet.value == PetType.dog;
      return Center(
        child: SizedBox(
          width: R.width(350),
          height: R.height(224),
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Image.asset(
                isDog
                    ? 'assets/images/dogwave.png'
                    : 'assets/images/catwave.png',
                width: R.width(350),
                height: R.height(224),
                fit: BoxFit.contain,
              ),
              /* 
              // Sound Waves from ear on the right side
              Positioned(
                right: -R.width(50),
                top: R.height(20),
                child: SizedBox(
                  width: R.width(80),
                  height: R.height(80),
                  child: CustomPaint(
                    painter: SoundWavePainter(
                      color: const Color(0xFFFFD700),
                      animationValue: 0.5,
                    ),
                  ),
                ),
              ),
              */
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBoxedWaveform() {
    return Container(
      width: R.width(361),
      height: R.height(48), // Slightly larger container for padding/shadow
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
        child: Obx(
          () => CustomPaint(
            size: Size(R.width(361), R.height(48)),
            painter: WaveformPainter(
              values: controller.waveformValues.toList(),
              color: controller.isPlaying.value
                  ? const Color(0xFF6C3BAA)
                  : Colors.grey.shade400,
              secondaryColor: controller.isPlaying.value
                  ? const Color(0xFF6C3BAA)
                  : Colors.grey.shade400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _assetIconButton(
          assetPath: 'assets/images/audio_button/retry.png',
          onTap: () {
            controller.reset();
            Get.back();
          },
        ),
        SizedBox(width: R.width(24)),
        /*
        _assetIconButton(
          assetPath: 'assets/images/audio_button/hold.png',
          onTap: () => controller.stopAudio(),
        ),
        SizedBox(width: R.width(24)),
        */
        Obx(
          () => _assetIconButton(
            assetPath: controller.isPlaying.value
                ? 'assets/images/audio_button/pause.png'
                : 'assets/images/audio_button/start_playing.png',
            onTap: () => controller.isPlaying.value
                ? controller.pauseAudio()
                : controller.playRecording(),
          ),
        ),
      ],
    );
  }

  Widget _assetIconButton({
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Image.asset(
        assetPath,
        width: R.width(48),
        height: R.width(48),
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildSaveVoiceSection() {
    return Obx(() {
      final resultTextLower = controller.resultText.value.toLowerCase();
      final isNoSoundDetected =
          !controller.isHumanToDog.value &&
          (controller.resultText.value.isEmpty ||
              resultTextLower.contains("no dog sound detected") ||
              resultTextLower.contains("no cat sound detected") ||
              resultTextLower.contains("silence") ||
              resultTextLower.contains("blocked") ||
              resultTextLower.contains("error"));

      final isLabelEmpty = controller.voiceLabel.value.isEmpty;
      final isSaving = controller.isSaving.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Save voice",
            style: AppTypography.labelXs.copyWith(
              color: isNoSoundDetected
                  ? Colors.grey.shade400
                  : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: R.height(8)),
          TextFormField(
            enabled: !isNoSoundDetected,
            onChanged: (val) => controller.voiceLabel.value = val,
            decoration: InputDecoration(
              hintText: controller.isHumanToDog.value
                  ? "ie. Hello boy"
                  : (isNoSoundDetected ? "No sound detected" : "Snack"),
              hintStyle: AppTypography.bodyMd.copyWith(
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF6C3BAA)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: R.width(20),
                vertical: R.height(18),
              ),
              fillColor: isNoSoundDetected
                  ? Colors.grey.shade50
                  : Colors.transparent,
              filled: isNoSoundDetected,
            ),
          ),
          SizedBox(height: R.height(24)),
          AppMaterialButton(
            label: isSaving
                ? "Saving…"
                : (isNoSoundDetected
                      ? "Cannot save (No sound)"
                      : (isLabelEmpty ? "Talk again" : "Save sound")),
            onPressed: (isSaving || isNoSoundDetected)
                ? null
                : () {
                    if (isLabelEmpty) {
                      controller.reset();
                      Get.back();
                    } else {
                      controller.saveVoice();
                    }
                  },
            height: R.height(56),
            borderRadius: 30,
            backgroundColor: isNoSoundDetected
                ? Colors.grey.shade200
                : const Color(0xFF6C3BAA),
            textColor: isNoSoundDetected ? Colors.grey.shade400 : Colors.white,
          ),
          SizedBox(height: R.height(20)),
        ],
      );
    });
  }
}
