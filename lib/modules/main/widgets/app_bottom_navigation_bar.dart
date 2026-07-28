import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/modules/notification/controllers/notification_controller.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/app_asset_image.dart';
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
          bottom: R.height(8),
          top: R.height(4),
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
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: R.height(8)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.25),
                      Colors.white.withValues(alpha: 0.08),
                    ],
                  ),
                ),
                child: Obx(
                  () => SizedBox(
                    height: R.height(40),
                    child: Stack(
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
                                height: R.height(40),
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
                                  showBadge: true,
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
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String assetPath, {
    bool showBadge = false,
  }) {
    final isSelected = controller.currentIndex.value == index;

    return GestureDetector(
      onTap: () => controller.changeTabIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: SizedBox(
          width: R.width(52),
          height: R.height(40),
          child: Center(
            child: TweenAnimationBuilder<Color?>(
              duration: const Duration(milliseconds: 250),
              tween: ColorTween(
                begin: const Color(0xFF0A0A0A),
                end: isSelected ? Colors.white : const Color(0xFF0A0A0A),
              ),
              builder: (context, color, child) {
                final icon = AppAssetImage(
                  assetPath,
                  width: R.width(32),
                  height: R.height(32),
                  fit: BoxFit.contain,
                  color: color,
                  colorBlendMode: BlendMode.srcIn,
                );

                if (!showBadge) return icon;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    icon,
                    Positioned(
                      right: -R.width(2),
                      top: -R.height(2),
                      child: _NotificationBadge(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<NotificationController>()) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final count = Get.find<NotificationController>().unreadCount.value;
      if (count <= 0) return const SizedBox.shrink();

      final label = count > 9 ? '9+' : '$count';

      return Container(
        constraints: BoxConstraints(
          minWidth: R.width(16),
          minHeight: R.height(16),
        ),
        padding: EdgeInsets.symmetric(horizontal: R.width(4)),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(R.width(10)),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: R.font(9),
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      );
    });
  }
}
