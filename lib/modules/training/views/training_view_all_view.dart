import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import '../controllers/training_controller.dart';
import '../models/training_item.dart';
import 'package:cached_network_image/cached_network_image.dart';

class TrainingViewAllView extends GetView<TrainingController> {
  const TrainingViewAllView({super.key});

  @override
  Widget build(BuildContext context) {
    final category = Get.arguments as String;
    final items = category.contains("COMMAND")
        ? controller.basicCommands
        : controller.tricks;

    return AppScaffold(
      backgroundColor: Colors.white,
      horizontalPadding: 0,
      // Keep the existing SafeArea wrapper below to avoid changing layout.
      useSafeArea: false,
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
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: R.height(16),
                    crossAxisSpacing: R.width(16),
                    childAspectRatio: 110 / 106,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
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
    final isLocked = controller.isItemLocked(item);
    
    Widget imageWidget = item.isNetworkImage
        ? CachedNetworkImage(
            imageUrl: item.fullImageUrl.replaceAll(' ', '%20'),
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.broken_image,
              size: 24,
              color: Colors.grey,
            ),
          )
        : Image.asset(
            item.imageUrl ?? 'assets/images/play dog 1.png',
            fit: BoxFit.contain,
          );

    if (isLocked) {
      imageWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0,      0,      0,      1, 0,
        ]),
        child: imageWidget,
      );
    }

    return GestureDetector(
      onTap: () => controller.goToDetail(item),
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
                color: const Color(0xFFFFF0E1).withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(R.width(1)),
                    child: Opacity(
                      opacity: isLocked ? 0.5 : 1.0,
                      child: imageWidget,
                    ),
                  ),
                  if (isLocked)
                    Center(
                      child: Image.asset(
                        'assets/images/Buton.png',
                        width: R.width(36),
                        height: R.width(36),
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
            ),
            const Spacer(),
            Text(
              item.name,
              style: AppTypography.bodyXs.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
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
