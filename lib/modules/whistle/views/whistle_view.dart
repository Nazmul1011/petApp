import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/app_header.dart';
import '../controllers/whistle_controller.dart';

class WhistleView extends GetView<WhistleController> {
  const WhistleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppHeader(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: R.width(24),
              vertical: R.height(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Whistle",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.info, color: Colors.black),
                  onPressed: () => _showInfoSheet(context),
                ),
              ],
            ),
          ),
          const Spacer(flex: 2),
          // Whistle Pulse Button Area
          AnimatedBuilder(
            animation: controller.pulseController,
            builder: (context, child) {
              return GestureDetector(
                onTap: () {
                  controller.toggleWhistle();
                },
                child: Obx(() {
                  final isplaying = controller.isPlaying.value;
                  // When playing, the pulse circle expands and fades
                  final pulseScale =
                      1.0 + (controller.pulseController.value * 0.3);
                  final pulseOpacity = 1.0 - controller.pulseController.value;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer pulse ring (only visible if playing)
                      if (isplaying)
                        Transform.scale(
                          scale: pulseScale,
                          child: Container(
                            width: 220,
                            height: 220,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(
                                0xFF8B78E6,
                              ).withOpacity(pulseOpacity * 0.4),
                            ),
                          ),
                        ),
                      // Outer border ring (visible when NOT playing)
                      if (!isplaying)
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                        ),
                      // Main central button
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 190,
                        height: 190,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isplaying
                              ? const Color(0xFF8B78E6)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/whistle.png',
                            width: 80,
                            height: 80,
                            color: isplaying
                                ? Colors.white
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              );
            },
          ),

          const Spacer(flex: 2),

          // Frequency Display
          Obx(
            () => Text(
              "${controller.frequency.value.toInt()} Hz",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),

          // Frequency Slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Obx(() {
              return SliderTheme(
                data: SliderThemeData(
                  trackHeight: 24,
                  activeTrackColor: const Color(0xFF8B78E6),
                  inactiveTrackColor: Colors.grey.withOpacity(0.15),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 18.0,
                    elevation: 4.0,
                  ),
                  overlayColor: const Color(0xFF8B78E6).withOpacity(0.2),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 28.0,
                  ),
                ),
                child: Slider(
                  value: controller.frequency.value,
                  min: 0,
                  max: 22000,
                  onChanged: (val) {
                    controller.updateFrequency(val);
                  },
                ),
              );
            }),
          ),
          const Spacer(flex: 1),
        ],
      ),
    );
  }

  void _showInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: R.width(24),
            right: R.width(24),
            top: R.height(24),
            bottom: MediaQuery.of(context).padding.bottom + R.height(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Whistle instruction",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: R.height(24)),
                _buildSectionTitle("What this does"),
                _buildSectionBody(
                  "The whistle emits a high-frequency sound designed to get your pet’s attention quickly. Dogs and cats often respond to these tones even when they ignore regular voice commands.",
                ),
                SizedBox(height: R.height(20)),
                _buildSectionTitle("How to use it"),
                _buildSectionBody(
                  "Use the whistle to call your pet, interrupt unwanted behavior, or start a training moment. Short, consistent whistles work better than long or repeated use.",
                ),
                SizedBox(height: R.height(20)),
                _buildSectionTitle("When it works best"),
                _buildSectionBody(
                  "Whistles are most effective in calm or moderately noisy environments and when paired with positive reinforcement like praise or treats.",
                ),
                SizedBox(height: R.height(20)),
                _buildSectionTitle("Important notes"),
                _buildBulletPoint("Not all pets respond the same way."),
                _buildBulletPoint(
                  "Avoid overuse to prevent stress or desensitization.",
                ),
                _buildBulletPoint(
                  "Stop immediately if your pet shows signs of discomfort.",
                ),
                SizedBox(height: R.height(24)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(R.width(16)),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7EA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFCC80).withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tip",
                        style: TextStyle(
                          color: Color(0xFFFF9900),
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: R.height(8)),
                      Text(
                        "For best results, use the whistle consistently for the same purpose so your pet learns what it means.",
                        style: TextStyle(
                          color: const Color(0xFFFF9900).withOpacity(0.9),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.height(8)),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSectionBody(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 13, color: Colors.grey.shade700, height: 1.5),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.height(8)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: R.height(6),
              right: R.width(10),
              left: R.width(4),
            ),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade500,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
