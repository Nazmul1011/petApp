import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Microphone/Speaker Ring
                _buildMicButton(),
                SizedBox(height: R.height(60)),
                
                // Toggle Switcher (Pet vs Human)
                _buildModeToggle(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: R.width(24),
          vertical: R.height(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/Logo_image.png',
              height: R.height(40),
            ),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(R.width(8)),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFFFF7EA),
                  ),
                  child: const Icon(
                    Icons.workspace_premium,
                    color: Color(0xFFFF9900),
                    size: 20,
                  ),
                ),
                SizedBox(width: R.width(12)),
                Container(
                  width: R.width(36),
                  height: R.width(36),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('assets/images/dog image.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.black54),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton() {
     return Container(
      width: R.width(260),
      height: R.width(260),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Center(
        child: Container(
          width: R.width(220),
          height: R.width(220),
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
          child: Center(
            child: Icon(
              Icons.mic,
              size: R.width(60),
              color: const Color(0xFF7F67CB),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      width: R.width(160),
      height: R.height(48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(R.width(24)),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => controller.togglePetMode(false),
            child: Obx(
              () => Icon(
                Icons.face,
                color: !controller.isPetMode.value
                    ? const Color(0xFF7F67CB)
                    : Colors.grey,
              ),
            ),
          ),
          const Icon(Icons.swap_horiz, color: Color(0xFF7F67CB)),
          GestureDetector(
            onTap: () => controller.togglePetMode(true),
            child: Obx(
              () => Container(
                padding: EdgeInsets.all(R.width(2)),
                decoration: controller.isPetMode.value 
                  ? const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF3F1FF))
                  : null,
                child: Icon(
                  Icons.pets,
                  size: 20,
                  color: controller.isPetMode.value
                      ? const Color(0xFF7F67CB)
                      : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
