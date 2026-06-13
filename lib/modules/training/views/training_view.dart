import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/app_header.dart';
import '../controllers/training_controller.dart';
import '../models/training_item.dart';
import 'package:petapp/core/routes/app_routes.dart';
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
                  Obx(() {
                    if (controller.isLoading.value) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: R.height(100)),
                          child: const CircularProgressIndicator(
                            color: Color(0xFF6C3BAA),
                          ),
                        ),
                      );
                    }
                    
                    final allItems = [
                      ...controller.basicCommands,
                      ...controller.tricks,
                    ];
                    
                    if (allItems.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: R.height(100)),
                          child: Text(
                            "No training content found for your pet.\nPlease check your connection.",
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyLg,
                          ),
                        ),
                      );
                    }
                    
                    return GridView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: allItems.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: R.height(16),
                        crossAxisSpacing: R.width(16),
                        childAspectRatio: 169 / 166,
                      ),
                      itemBuilder: (context, index) {
                        return _buildGridItem(allItems[index], context);
                      },
                    );
                  }),
                  SizedBox(height: R.height(40)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(TrainingItem item, BuildContext context) {
    final isLocked = controller.isItemLocked(item);
    
    Widget imageWidget = item.isNetworkImage
        ? CachedNetworkImage(
            imageUrl: item.fullImageUrl.replaceAll(' ', '%20'),
            fit: BoxFit.contain,
            placeholder: (context, url) => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF6C3BAA),
                ),
              ),
            ),
            errorWidget: (context, url, error) => const Icon(
              Icons.broken_image,
              color: Colors.grey,
              size: 24,
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
      onTap: () {
        if (isLocked) {
          Get.toNamed(AppRoutes.payment);
        } else {
          _showTrainingDetailSheet(context, item);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.width(12),
          vertical: R.height(12),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE8E8E8), width: 1.5),
        ),
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: isLocked ? 0.5 : 1.0,
                    child: imageWidget,
                  ),
                  if (isLocked)
                    Center(
                      child: Image.asset(
                        'assets/images/Buton.png',
                        width: R.width(44),
                        height: R.width(44),
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: R.height(4)),
            Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontSize: 16,
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

  void _showTrainingDetailSheet(BuildContext context, TrainingItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: R.width(24),
            right: R.width(24),
            top: R.height(8),
            bottom: MediaQuery.of(context).padding.bottom + R.height(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: item.isNetworkImage
                      ? CachedNetworkImage(
                          imageUrl: item.fullImageUrl.replaceAll(' ', '%20'),
                          width: double.infinity,
                          height: R.height(200),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: R.height(200),
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: R.height(200),
                            color: Colors.grey.shade100,
                            child: const Icon(Icons.broken_image, size: 40),
                          ),
                        )
                      : Image.asset(
                          item.imageUrl ?? 'assets/images/play dog 1.png',
                          width: double.infinity,
                          height: R.height(200),
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(height: R.height(24)),
                if (item.position.isNotEmpty) ...[
                  _buildModalSectionTitle("Position"),
                  _buildModalSectionBody(item.position),
                  SizedBox(height: R.height(20)),
                ],
                if (item.command.isNotEmpty) ...[
                  _buildModalSectionTitle("Command"),
                  _buildModalSectionBody(item.command),
                  SizedBox(height: R.height(20)),
                ],
                if (item.guidance.isNotEmpty) ...[
                  _buildModalSectionTitle("Guidance"),
                  _buildModalSectionBody(item.guidance),
                  SizedBox(height: R.height(20)),
                ],
                if (item.confirmation.isNotEmpty) ...[
                  _buildModalSectionTitle("Confirmation"),
                  _buildModalSectionBody(item.confirmation),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: R.height(6)),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildModalSectionBody(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: Colors.grey.shade800,
        height: 1.4,
      ),
    );
  }
}
