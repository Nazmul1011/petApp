import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/app_header.dart';
import '../controllers/emotions_controller.dart';
import '../models/emotion_item.dart';

class EmotionsView extends GetView<EmotionsController> {
  const EmotionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: R.width(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: R.height(10)),
                  Text(
                    "Emotions",
                    style: AppTypography.h5.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                  SizedBox(height: R.height(24)),
                  Obx(
                    () => GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.emotions.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: R.height(16),
                        crossAxisSpacing: R.width(16),
                        childAspectRatio: 0.85,
                      ),
                      itemBuilder: (context, index) {
                        return _buildEmotionCard(controller.emotions[index]);
                      },
                    ),
                  ),
                  SizedBox(height: R.height(40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionCard(EmotionItem item) {
    return GestureDetector(
      onTap: () => controller.selectEmotion(item),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: item.isLocked
                    ? Colors.grey.shade400
                    : const Color(0xFFFFF0E1).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(R.width(8)),
                    child: Opacity(
                      opacity: item.isLocked ? 0.5 : 1.0,
                      child: Image.asset(
                        item.imagePath,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (item.isLocked)
                    const Center(
                      child: Icon(Icons.lock, color: Colors.white, size: 28),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: R.height(8)),
          Text(
            item.name,
            style: AppTypography.bodyXs.copyWith(
              fontWeight: FontWeight.w600,
              color: item.isLocked ? Colors.black45 : Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
