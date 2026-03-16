import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import '../controllers/main_navigation_controller.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<MainNavigationController>();

    return Container(
      height: R.height(90),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Obx(() => Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(nav, 0, Icons.forum_rounded, "Talk"),
            _buildNavItem(nav, 1, Icons.pets_rounded, "Emotions"),
            _buildNavItem(nav, 2, Icons.campaign_rounded, "Whistle"),
            _buildNavItem(nav, 3, Icons.psychology_rounded, "Training"),
            _buildNavItem(nav, 4, Icons.notifications_rounded, "Notification"),
            _buildNavItem(nav, 5, Icons.grid_view_rounded, "More"),
          ],
        )),
      ),
    );
  }

  Widget _buildNavItem(MainNavigationController nav, int index, IconData icon, String label) {
    final isSelected = nav.bottomNavIndex.value == index;
    final color = isSelected ? AppColors.primaryColor : Colors.grey.shade400;

    return GestureDetector(
      onTap: () => nav.switchTab(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: R.width(28)),
          SizedBox(height: R.height(4)),
          Text(
            label,
            style: AppTypography.labelXs.copyWith(
              color: color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: R.font(10),
            ),
          ),
        ],
      ),
    );
  }
}
