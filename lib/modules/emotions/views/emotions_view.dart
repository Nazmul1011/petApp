import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/app_header.dart';
import '../controllers/emotions_controller.dart';
import '../models/emotion_item.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
                  SizedBox(height: R.height(12)),
                  Obx(
                    () => controller.isLoading.value
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: R.height(100)),
                              child: const CircularProgressIndicator(
                                color: Color(0xFF8C52FF),
                              ),
                            ),
                          )
                        : controller.emotions.isEmpty
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: R.height(100)),
                              child: Text(
                                "No emotions found for your pet.\nPlease check your connection.",
                                textAlign: TextAlign.center,
                                style: AppTypography.bodyLg,
                              ),
                            ),
                          )
                        : GridView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.emotions.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: R.height(16),
                                  crossAxisSpacing: R.width(16),
                                  childAspectRatio: 110 / 106,
                                ),
                            itemBuilder: (context, index) {
                              return _buildEmotionCard(
                                controller.emotions[index],
                              );
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
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.width(8),
          vertical: R.height(6),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8E8E8), width: 1),
        ),
        child: Column(
          children: [
            Container(
              width: R.width(94),
              height: R.height(60),
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
                    padding: EdgeInsets.all(R.width(1)),
                    child: Opacity(
                      opacity: item.isLocked ? 0.5 : 1.0,
                      child: item.imagePath.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: item.imagePath,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.contain,
                              imageBuilder: (context, imageProvider) => Transform.scale(
                                scale: 2.3,
                                child: Image(
                                  image: imageProvider,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              placeholder: (context, url) => const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF8C52FF),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                                size: 24,
                              ),
                            )
                          : Transform.scale(
                              scale: 2.3,
                              child: Image.asset(
                                item.imagePath,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                              ),
                            ),
                    ),
                  ),
                  if (item.isLocked)
                    const Center(
                      child: Icon(Icons.lock, color: Colors.white, size: 20),
                    ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              item.name,
              style: AppTypography.bodyXs.copyWith(
                fontWeight: FontWeight.w600,
                color: item.isLocked ? Colors.black45 : Colors.black87,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
