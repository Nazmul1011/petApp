import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

import '../controllers/legal_controller.dart';
import '../widgets/legal_tab_button.dart';

class LegalView extends GetView<LegalController> {
  const LegalView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      horizontalPadding: 0,
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top App Bar Area
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: R.width(20),
                vertical: R.height(20),
              ),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),

            // Tab Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.width(20)),
              child: Obx(
                () => Row(
                  children: [
                    LegalTabButton(
                      title: "Privacy policy",
                      isSelected: controller.selectedTabIndex.value == 0,
                      onTap: () => controller.setTab(0),
                    ),
                    SizedBox(width: R.width(12)),
                    LegalTabButton(
                      title: "Terms and conditions",
                      isSelected: controller.selectedTabIndex.value == 1,
                      onTap: () => controller.setTab(1),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: R.height(24)),

            // Dynamic Title
            Padding(
              padding: EdgeInsets.symmetric(horizontal: R.width(20)),
              child: Obx(
                () => Text(
                  controller.selectedTabIndex.value == 0
                      ? "Privacy policy"
                      : "Terms and conditions",
                  style: AppTypography.h5.copyWith(
                    color: AppColors.headingText,
                  ),
                ),
              ),
            ),

            SizedBox(height: R.height(16)),

            // Content
            Expanded(
              child: Obx(() {
                final content = controller.selectedTabIndex.value == 0
                    ? controller.privacyContent
                    : controller.termsContent;

                return ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.width(20),
                    vertical: R.height(10),
                  ),
                  itemCount: content.length,
                  itemBuilder: (context, index) {
                    final item = content[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: R.height(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.heading,
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.headingText,
                            ),
                          ),
                          SizedBox(height: R.height(4)),
                          Text(
                            item.body,
                            style: AppTypography.labelSm.copyWith(
                              color: AppColors.bodyText,
                              fontWeight: FontWeight.normal,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
