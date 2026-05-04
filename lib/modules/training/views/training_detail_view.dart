import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import '../controllers/training_controller.dart';
import '../models/training_item.dart';

class TrainingDetailView extends GetView<TrainingController> {
  const TrainingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as TrainingItem;
    final prefix = item.category == 'BASIC' ? "Basic Command" : "Trick";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: R.width(24),
                vertical: R.height(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$prefix - ${item.name}",
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
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: R.width(24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: R.height(200),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E1).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(R.width(20)),
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: R.height(24)),
                    _buildTrainingSection("Position", item.position),
                    _buildTrainingSection("Command", item.command),
                    _buildTrainingSection("Guidance", item.guidance),
                    _buildTrainingSection("Confirmation", item.confirmation),
                    SizedBox(height: R.height(40)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingSection(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.subtitleMd.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        SizedBox(height: R.height(8)),
        Text(
          description,
          style: AppTypography.bodySm.copyWith(
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
        SizedBox(height: R.height(20)),
      ],
    );
  }
}
