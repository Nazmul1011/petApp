import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class AppEmptyState extends StatelessWidget {
  final IconData? icon;
  final String? iconAsset;
  final String title;
  final String description;

  const AppEmptyState({
    super.key,
    this.icon,
    this.iconAsset,
    required this.title,
    required this.description,
  }) : assert(icon != null || iconAsset != null);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: R.width(32)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: R.width(96),
              height: R.width(96),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: Center(child: _buildIcon()),
            ),
            SizedBox(height: R.height(16)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.subtitleMd.copyWith(
                color: AppColors.headingText,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: R.height(8)),
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.textSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (iconAsset != null) {
      return Image.asset(
        iconAsset!,
        width: R.width(32),
        height: R.width(32),
        fit: BoxFit.contain,
        color: AppColors.headingText,
        colorBlendMode: BlendMode.srcIn,
      );
    }

    return Icon(
      icon,
      size: R.width(32),
      color: AppColors.headingText,
    );
  }
}
