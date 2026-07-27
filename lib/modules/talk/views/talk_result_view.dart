import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/modules/onboarding/widgets/waveform_widgets.dart';
import 'package:petapp/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

class TalkResultView extends GetView<DashboardController> {
  const TalkResultView({super.key});

  bool get _isNoSoundMessage {
    final resultTextLower = controller.resultText.value.toLowerCase();
    if (controller.resultText.value.isEmpty) return true;
    return resultTextLower.contains('no dog sound detected') ||
        resultTextLower.contains('no cat sound detected') ||
        resultTextLower.contains('silence') ||
        resultTextLower.contains('blocked') ||
        resultTextLower.contains('error');
  }

  /// Only show play + save after a real pet→human match.
  /// Loading / no sound → retry only (no flash of save UI).
  bool get _hasSuccessfulResult =>
      !controller.isHumanToDog.value &&
      !controller.isLoading.value &&
      !_isNoSoundMessage;

  void _retry() {
    controller.reset();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.white,
      horizontalPadding: 0,
      body: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            controller.reset();
          }
        },
        child: Obx(() {
          final hasSuccess = _hasSuccessfulResult;
          return Column(
            children: [
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
                        if (controller.isHumanToDog.value) {
                          return const SizedBox.shrink();
                        }
                        // While loading, don't claim "no sound" yet
                        if (controller.isLoading.value &&
                            controller.resultText.value.isEmpty) {
                          return SizedBox(height: R.height(20));
                        }
                        final petLabel =
                            controller.selectedPet.value == PetType.dog
                            ? 'Dog'
                            : 'Cat';
                        final text = controller.resultText.value.isEmpty
                            ? "No $petLabel sound detected"
                            : controller.resultText.value;
                        final isNoSound = _isNoSoundMessage;
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
                              text,
                              style: AppTypography.h4.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isNoSound
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

                      if (hasSuccess)
                        _buildResultIcons()
                      else
                        _buildNoSoundRetryIcon(),

                      SizedBox(height: R.height(20)),
                    ],
                  ),
                ),
              ),
              if (hasSuccess)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: R.width(24)),
                  child: _buildSaveVoiceSection(),
                ),
            ],
          );
        }),
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
            ],
          ),
        ),
      );
    });
  }

  Widget _buildBoxedWaveform() {
    return Container(
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

  Widget _buildNoSoundRetryIcon() {
    return Center(
      child: _assetIconButton(
        assetPath: 'assets/images/audio_button/retry.png',
        onTap: _retry,
      ),
    );
  }

  Widget _buildResultIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _assetIconButton(
          assetPath: 'assets/images/audio_button/retry.png',
          onTap: _retry,
        ),
        SizedBox(width: R.width(24)),
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
      final isLabelEmpty = controller.voiceLabel.value.isEmpty;
      final isSaving = controller.isSaving.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Save voice",
            style: AppTypography.labelXs.copyWith(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: R.height(8)),
          TextFormField(
            onChanged: (val) => controller.voiceLabel.value = val,
            decoration: InputDecoration(
              hintText: "Snack",
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
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF6C3BAA)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: R.width(20),
                vertical: R.height(18),
              ),
            ),
          ),
          SizedBox(height: R.height(24)),
          AppMaterialButton(
            label: isSaving
                ? "Saving…"
                : (isLabelEmpty ? "Talk again" : "Save sound"),
            onPressed: isSaving
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
            backgroundColor: const Color(0xFF6C3BAA),
            textColor: Colors.white,
          ),
          SizedBox(height: R.height(20)),
        ],
      );
    });
  }
}
