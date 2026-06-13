import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import '../controllers/main_controller.dart';

class AppBottomNavigationBar extends GetView<MainController> {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: R.width(24),
          right: R.width(24),
          bottom: R.height(16),
          top: R.height(8),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: R.height(72),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Obx(
                  () => Stack(
                    children: [
                      AnimatedAlign(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOutCubic,
                        alignment: Alignment(
                          -1.0 + (controller.currentIndex.value / 5.0) * 2.0,
                          0.0,
                        ),
                        child: FractionallySizedBox(
                          widthFactor: 1 / 6,
                          child: Center(
                            child: Container(
                              width: R.width(52),
                              height: R.height(44),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9F82CE),
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: _buildNavItem(
                                0,
                                "assets/images/bottom_navigation/message-multiple.png",
                              ),
                            ),
                            Expanded(
                              child: _buildNavItem(
                                1,
                                "assets/images/bottom_navigation/pets.png",
                              ),
                            ),
                            Expanded(
                              child: _buildNavItem(
                                2,
                                "assets/images/bottom_navigation/whistle.png",
                              ),
                            ),
                            Expanded(
                              child: _buildNavItem(
                                3,
                                "assets/images/bottom_navigation/frisbee.png",
                              ),
                            ),
                            Expanded(
                              child: _buildNavItem(
                                4,
                                "assets/images/bottom_navigation/notification.png",
                              ),
                            ),
                            Expanded(
                              child: _buildNavItem(
                                5,
                                "assets/images/bottom_navigation/more.png",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String assetPath) {
    final isSelected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTabIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: SizedBox(
          width: R.width(52),
          height: R.height(44),
          child: Center(
            child: TweenAnimationBuilder<Color?>(
              duration: const Duration(milliseconds: 250),
              tween: ColorTween(
                begin: const Color(0xFF0A0A0A),
                end: isSelected ? Colors.white : const Color(0xFF0A0A0A),
              ),
              builder: (context, color, child) {
                return Image.asset(
                  assetPath,
                  width: R.width(24),
                  height: R.height(24),
                  fit: BoxFit.contain,
                  color: color,
                  colorBlendMode: BlendMode.srcIn,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
