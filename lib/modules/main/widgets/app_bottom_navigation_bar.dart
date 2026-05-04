import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import '../controllers/main_controller.dart';

class AppBottomNavigationBar extends GetView<MainController> {
  const AppBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: R.height(90),
      padding: EdgeInsets.only(bottom: R.height(10)),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
      ),
      child: Obx(
        () => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _buildNavItem(
                0,
                "Talk",
                "assets/images/bottom_navigation/message-multiple.png",
              ),
            ),
            Expanded(
              child: _buildNavItem(
                1,
                "Emotions",
                "assets/images/bottom_navigation/emotions.png",
              ),
            ),
            Expanded(
              child: _buildNavItem(
                2,
                "Whistle",
                "assets/images/bottom_navigation/whistle.png",
              ),
            ),
            Expanded(
              child: _buildNavItem(
                3,
                "Training",
                "assets/images/bottom_navigation/frisbee.png",
              ),
            ),
            Expanded(
              child: _buildNavItem(
                4,
                "Notification",
                "assets/images/bottom_navigation/notification.png",
              ),
            ),
            Expanded(
              child: _buildNavItem(
                5,
                "More",
                "assets/images/bottom_navigation/more.png",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, String label, String assetPath) {
    final isSelected = controller.currentIndex.value == index;
    final color = isSelected ? const Color(0xFF7F67CB) : Colors.grey;

    return GestureDetector(
      onTap: () => controller.changeTabIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ImageIcon(AssetImage(assetPath), color: color, size: 24),
          SizedBox(height: R.height(4)),
          Text(
            label,
            style: AppTypography.bodyXxs.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
