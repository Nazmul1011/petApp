import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import '../controllers/training_controller.dart';
import '../models/training_item.dart';

class TrainingViewAllView extends GetView<TrainingController> {
  const TrainingViewAllView({super.key});

  @override
  Widget build(BuildContext context) {
    final category = Get.arguments as String;
    final items = category.contains("COMMAND") 
        ? controller.basicCommands 
        : controller.tricks;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: R.width(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: R.height(20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    category.capitalizeFirst ?? category,
                    style: AppTypography.subtitleMd.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(R.width(4)),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              SizedBox(height: R.height(24)),
              Expanded(
                child: GridView.builder(
                  itemCount: items.length * 3, // Mocking more items as seen in screenshot
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: R.height(16),
                    crossAxisSpacing: R.width(16),
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index % items.length];
                    return _buildGridItem(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(TrainingItem item) {
    return GestureDetector(
      onTap: () => controller.goToDetail(item),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0E1).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(R.width(8)),
                    child: Image.asset(
                      item.imagePath,
                      fit: BoxFit.contain,
                    ),
                  ),
                  if (item.isLocked)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.lock, color: Colors.white, size: 24),
                      ),
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
              color: Colors.black87,
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
