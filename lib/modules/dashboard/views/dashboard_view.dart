import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/app_header.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Obx(() {
              switch (controller.uiState.value) {
                case TranslationUIState.idle:
                  return _buildIdleState();
                case TranslationUIState.recording:
                  return _buildRecordingState();
                case TranslationUIState.result:
                  return _buildResultState();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: controller.startRecording,
          child: Container(
            width: R.width(180),
            height: R.width(180),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            ),
            child: Container(
              margin: EdgeInsets.all(R.width(20)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.mic, color: Colors.grey, size: 40),
              ),
            ),
          ),
        ),
        SizedBox(height: R.height(80)),
        _buildModeToggle(),
      ],
    );
  }

  Widget _buildRecordingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildAudioVisualizer(active: true),
        SizedBox(height: R.height(40)),
        GestureDetector(
          onTap: controller.stopRecording,
          child: Container(
            width: R.width(140),
            height: R.width(140),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF7F67CB), // Purple
            ),
            child: const Center(
              child: Icon(Icons.mic, color: Colors.white, size: 50),
            ),
          ),
        ),
        SizedBox(height: R.height(80)),
        // Placeholder to keep spacing identical
        SizedBox(height: R.height(56)),
      ],
    );
  }

  Widget _buildResultState() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.width(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),

          if (!controller.isHumanToDog.value)
            Text(
              controller.resultText.value,
              style: AppTypography.h4.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  controller.selectedPet.value == PetType.dog
                      ? 'assets/images/dog_happy_face.png'
                      : 'assets/images/play cat 1.png',
                  height: R.height(100),
                ),
                SizedBox(width: R.width(10)),
                Icon(
                  Icons.waves,
                  color: Colors.yellow.shade700,
                  size: R.width(40),
                ),
              ],
            ),

          SizedBox(height: R.height(40)),

          Opacity(opacity: 0.3, child: _buildAudioVisualizer(active: false)),

          SizedBox(height: R.height(30)),

          _buildResultIcons(),

          const Spacer(flex: 2),

          // Save Voice Input
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Save voice",
              style: AppTypography.labelXs.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          SizedBox(height: R.height(8)),
          TextFormField(
            onChanged: (val) => controller.voiceLabel.value = val,
            decoration: InputDecoration(
              hintText: controller.isHumanToDog.value
                  ? "ie. Hello boy"
                  : "Snack",
              hintStyle: AppTypography.bodyMd.copyWith(
                color: Colors.grey.shade400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.width(30)),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.width(30)),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(R.width(30)),
                borderSide: const BorderSide(color: Color(0xFF7F67CB)),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: R.width(20),
                vertical: R.height(16),
              ),
            ),
          ),

          SizedBox(height: R.height(16)),

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
                      } else {
                        controller.saveVoice();
                      }
                    },
              height: R.height(56),
              borderRadius: 30,
              backgroundColor: const Color(0xFF7F67CB),
              textColor: Colors.white,
            );
          }),

          SizedBox(height: R.height(40)), // Padding for bottom nav visual
        ],
      ),
    );
  }

  Widget _buildResultIcons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleIconButton(icon: Icons.refresh, onTap: () => controller.reset()),
        SizedBox(width: R.width(20)),
        _circleIconButton(
          icon: Icons.stop,
          onTap: () => controller.stopAudio(),
          isSolid: true,
        ),
        SizedBox(width: R.width(20)),
        Obx(
          () => _circleIconButton(
            icon: controller.isPlaying.value ? Icons.pause : Icons.play_arrow,
            onTap: () => controller.isPlaying.value
                ? controller.pauseAudio()
                : controller.playRecording(),
            isSolid: true,
          ),
        ),
      ],
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isSolid = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: R.width(72),
        height: R.width(72),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: isSolid
              ? Container(
                  width: R.width(48),
                  height: R.width(48),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black87,
                  ),
                  child: Icon(icon, color: Colors.white, size: R.width(20)),
                )
              : Icon(icon, color: Colors.black54, size: R.width(28)),
        ),
      ),
    );
  }

  Widget _buildAudioVisualizer({required bool active}) {
    return SizedBox(
      height: R.height(50),
      child: Obx(() {
        // Tie to amplitude stream -> fake visualizer effect
        double amp = controller.amplitude.value;
        double normalized = (amp + 160) / 160;
        normalized = normalized.clamp(0.0, 1.0);

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(24, (index) {
            // For a wavy look, use sine/random math
            double baseHeight = active
                ? max(6.0, 50 * normalized * Random().nextDouble())
                : 6.0 + (sin(index) * 4).abs();

            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 4,
              height: active ? baseHeight : (index % 2 == 0 ? 10 : 4),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF7F67CB).withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      }),
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
                  color: Color(0xFF7F67CB),
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
        'assets/images/dog_happy_face.png',
        width: R.width(28),
        height: R.width(28),
        fit: BoxFit.contain,
      );
    }
  }
}
