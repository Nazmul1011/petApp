import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/material_button/app_material_button.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';

import '../controllers/language_controller.dart';
import '../widgets/language_item.dart';

class LanguageView extends GetView<LanguageController> {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      horizontalPadding: 0,
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Top Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: R.width(20),
                vertical: R.height(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select language",
                    style: AppTypography.subtitleLg.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: R.width(32),
                      height: R.width(32),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: R.height(10)),

            // Language List (Non-scrollable as requested, directly mapping items inside Expanded/Column)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: R.width(20)),
                child: Obx(
                  () => Column(
                    children: controller.languages.map((lang) {
                      return LanguageItem(
                        title: lang.name,
                        subtitle: lang.nativeName,
                        flagAsset: lang.flagAsset,
                        isSelected:
                            controller.selectedLanguageId.value == lang.id,
                        onTap: () => controller.selectLanguage(lang.id),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            // Bottom Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: R.width(20),
                vertical: R.height(20),
              ),
              child: AppMaterialButton(
                label: "Continue",
                onPressed: () => controller.continueWithSelection(),
                height: R.height(58),
                borderRadius: R.width(30),
                backgroundColor: const Color(0xFF7F67CB),
                textColor: Colors.white,
                textStyle: AppTypography.labelMd.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
