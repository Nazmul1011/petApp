import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class FeatureList extends StatelessWidget {
  const FeatureList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: R.width(4),
              runSpacing: R.height(4),
              children: [
                  _buildFeatureItem("No ads, no data sold"),
                  _buildFeatureItem("Unlock all emojis and sounds"),
                  _buildFeatureItem("All tricks & commands guide"),
                  _buildFeatureItem("Lifetime features & future AI upgrades"),
                  _buildFeatureItem("Unlimited Human to Dog/Cat translation"),
              ],
            )
        ],
      )
    );
  }

  Widget _buildFeatureItem(String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: R.width(4), color: AppColors.primaryColor),
        SizedBox(width: R.width(4)),
        Text(
          text,
          style: AppTypography.bodyXs.copyWith(
            color: AppColors.headingText,
          ),
        ),
      ],
    );
  }
}
