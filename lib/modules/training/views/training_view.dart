import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/app_header.dart';
import '../controllers/training_controller.dart';
import '../models/training_item.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cached_network_image/cached_network_image.dart';
class TrainingView extends GetView<TrainingController> {
  const TrainingView({super.key});

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
                    "Training",
                    style: AppTypography.h5.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                  SizedBox(height: R.height(24)),
                  Obx(
                    () => _buildSection(
                      title: "BASIC COMMANDS",
                      items: controller.basicCommands.take(3).toList(),
                    ),
                  ),
                  SizedBox(height: R.height(32)),
                  Obx(
                    () => _buildSection(
                      title: "TRICKS",
                      items: controller.tricks.take(3).toList(),
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

  Widget _buildSection({
    required String title,
    required List<TrainingItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTypography.labelXs.copyWith(
                color: Colors.grey.shade600,
                letterSpacing: 0.5,
              ),
            ),
            GestureDetector(
              onTap: () => controller.goToViewAll(title),
              child: Text(
                "VIEW ALL",
                style: AppTypography.labelXs.copyWith(
                  color: const Color(0xFF7F67CB),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: R.height(16)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: R.height(16),
            crossAxisSpacing: R.width(16),
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            return _buildGridItem(items[index]);
          },
        ),
      ],
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
                    child: item.isNetworkImage
                        ? CachedNetworkImage(
                            imageUrl: '${dotenv.env['BASE_URL'] ?? ''}${item.fullImageUrl}'
                                .replaceAll(' ', '%20'),
                            fit: BoxFit.contain,
                            placeholder: (context, url) => const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 40,
                            ),
                          )
                        : Image.asset(
                            item.imageUrl ?? 'assets/images/play dog 1.png',
                            fit: BoxFit.contain,
                          ),
                  ),
                  if (controller.isItemLocked(item))
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
