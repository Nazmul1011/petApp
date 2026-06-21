import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/onboarding/widgets/waveform_widgets.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/modules/dashboard/controllers/dashboard_controller.dart';

class TalkHumanToPetView extends GetView<DashboardController> {
  const TalkHumanToPetView({super.key});

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

                    // Large Pet Image with Sound Waves
                    _buildPetLogo(),

                    SizedBox(height: R.height(30)),

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

  Widget _buildPetLogo() {
    return Obx(() {
      final isDog = controller.selectedPet.value == PetType.dog;
      return Center(
        child: SizedBox(
          width: R.width(350),
          height: R.height(224),
          child: Image.asset(
            isDog ? 'assets/images/dogwave.png' : 'assets/images/catwave.png',
            width: R.width(350),
            height: R.height(224),
            fit: BoxFit.contain,
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
            hintText: "ie. Hello boy",
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
        Obx(() {
          final isLabelEmpty = controller.voiceLabel.value.isEmpty;
          final isSaving = controller.isSaving.value;
          return AppMaterialButton(
            label: isSaving
                ? "Saving…"
                : isLabelEmpty
                ? "Talk again"
                : "Save and continue",
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
          );
        }),
        SizedBox(height: R.height(20)),
      ],
    );
  }
}
