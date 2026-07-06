import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/app_header.dart';
import 'package:petapp/shared/widgets/dashboard_page_title.dart';
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
          const DashboardPageTitle(title: 'Training'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: R.width(24)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        childAspectRatio: 169 / 116,
                      ),
                      itemBuilder: (context, index) {
                        return _buildGridItem(allItems[index], context);
                      },
                    );
                  }),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + R.height(100),
                  ),
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
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
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
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
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
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: R.height(700),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: R.height(8),
              bottom: MediaQuery.of(context).padding.bottom + R.height(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: item.isNetworkImage
                        ? CachedNetworkImage(
                            imageUrl: item.fullImageUrl.replaceAll(' ', '%20'),
                            width: R.width(350),
                            height: R.height(196),
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: R.width(350),
                              height: R.height(196),
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: R.width(350),
                              height: R.height(196),
                              color: Colors.grey.shade100,
                              child: const Icon(Icons.broken_image, size: 40),
                            ),
                          )
                        : Image.asset(
                            item.imageUrl ?? 'assets/images/play dog 1.png',
                            width: R.width(350),
                            height: R.height(196),
                            fit: BoxFit.cover,
                          ),
                  ),
                ),
                SizedBox(height: R.height(24)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: R.width(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
