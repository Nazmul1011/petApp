import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'dart:math' as math;
import '../controllers/more_controller.dart';

class MoreView extends GetView<MoreController> {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "More",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.width(20),
          vertical: R.height(16),
        ),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: R.width(16),
          crossAxisSpacing: R.width(16),
          childAspectRatio: 0.95,
          children: [
            _buildGridItem(
              imagePath: "assets/images/icon/pet_profile.png",
              label: "Pet profile",
              iconColor: const Color(0xFF8B78E6),
              bgColor: const Color(0xFF8B78E6).withOpacity(0.12),
              onTap: () {},
            ),
            _buildGridItem(
              imagePath: "assets/images/icon/mood_history.png",
              label: "Mood History",
              iconColor: const Color(0xFFFF8A65),
              bgColor: const Color(0xFFFF8A65).withOpacity(0.12),
              onTap: () {},
            ),
            _buildGridItem(
              imagePath: "assets/images/icon/Saved_talk.png",
              label: "Saved Talks",
              iconColor: const Color(0xFFF06292),
              bgColor: const Color(0xFFF06292).withOpacity(0.12),
              onTap: () {},
            ),
            _buildGridItem(
              imagePath: "assets/images/icon/Language.png",
              label: "Language",
              iconColor: const Color(0xFF4DB6AC),
              bgColor: const Color(0xFF4DB6AC).withOpacity(0.12),
              onTap: () {},
            ),
            _buildGridItem(
              imagePath: "assets/images/icon/Subscription.png",
              label: "Subscription",
              iconColor: const Color(0xFF4DD0E1),
              bgColor: const Color(0xFF4DD0E1).withOpacity(0.12),
              onTap: () {},
            ),
            _buildGridItem(
              imagePath: "assets/images/icon/Others.png",
              label: "Others",
              iconColor: const Color(0xFFFFB300),
              bgColor: const Color(0xFFFFB300).withOpacity(0.12),
              onTap: () {},
            ),
            _buildGridItem(
              imagePath: "assets/images/icon/Support.png",
              label: "Support",
              iconColor: const Color(0xFFFF8A65),
              bgColor: const Color(0xFFFF8A65).withOpacity(0.12),
              onTap: () {},
            ),
            _buildGridItem(
              imagePath: "assets/images/icon/Rate_Us.png",
              label: "Rate us",
              iconColor: const Color(0xFFFFB300),
              bgColor: const Color(0xFFFFB300).withOpacity(0.12),
              onTap: () {},
            ),
            _buildGridItem(
              imagePath: "assets/images/icon/Share_app.png",
              label: "Share app",
              iconColor: const Color(0xFF5C6BC0),
              bgColor: const Color(0xFF5C6BC0).withOpacity(0.12),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridItem({
    IconData? icon,
    Widget? customIcon,
    String? imagePath,
    required String label,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: R.width(48),
              height: R.width(48),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Center(
                child: imagePath != null
                    ? Image.asset(
                        imagePath,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      )
                    : (customIcon ?? Icon(icon, color: iconColor, size: 24)),
              ),
            ),
            SizedBox(height: R.height(12)),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
