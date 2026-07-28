import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/app_header.dart';
import 'package:petapp/shared/widgets/dashboard_page_title.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/widgets/app_asset_image.dart';
import '../controllers/emotions_controller.dart';
import '../models/emotion_item.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EmotionsView extends GetView<EmotionsController> {
  const EmotionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: Colors.white,
      horizontalPadding: 0,
      // This page lives inside `MainView` which already uses `extendBody: true`
      // with the floating bottom nav. Avoid adding bottom SafeArea padding here,
      // otherwise you get an extra "white strip" under the nav.
      useSafeArea: false,
      body: Column(
        children: [
          const AppHeader(),
          const DashboardPageTitle(title: 'Emotions'),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: R.width(24),
                right: R.width(24),
                // Keep content above the floating bottom nav, but let background
                // extend behind it.
                bottom: MediaQuery.of(context).padding.bottom + R.height(56),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: R.height(12)),
                  Obx(
                    () => controller.isLoading.value
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: R.height(100)),
                              child: const CircularProgressIndicator(
                                color: Color(0xFF6C3BAA),
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
                                  crossAxisCount: 2,
                                  mainAxisSpacing: R.height(16),
                                  crossAxisSpacing: R.width(16),
                                  childAspectRatio: 169 / 166,
                                ),
                            itemBuilder: (context, index) {
                              return _buildEmotionCard(
                                controller.emotions[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmotionCard(EmotionItem item) {
    Widget imageWidget = item.imagePath.startsWith('http')
        ? CachedNetworkImage(
            imageUrl: item.imagePath,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            imageBuilder: (context, imageProvider) => Transform.scale(
              scale: 1.25,
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
        : Transform.scale(
            scale: 1.25,
            child: AppAssetImage(
              item.imagePath,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.contain,
            ),
          );

    if (item.isLocked) {
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
      onTap: () => controller.selectEmotion(item),
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
                    opacity: item.isLocked ? 0.5 : 1.0,
                    child: imageWidget,
                  ),
                  if (item.isLocked)
                    Center(
                      child: AppAssetImage(
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
}
