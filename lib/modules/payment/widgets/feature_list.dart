import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class FeatureList extends StatelessWidget {
  const FeatureList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: R.width(10),
          runSpacing: R.height(4),
          children: [
            _buildFeatureItem("No ads, no data sold"),
            _buildFeatureItem("Unlock all emojis and sounds"),
            _buildFeatureItem("All tricks & commands guide"),
            _buildFeatureItem("Lifetime features & future AI upgrades"),
            _buildFeatureItem("Unlimited Human to Dog/Cat translation"),
          ],
        ),
        SizedBox(height: R.height(12)),
      ],
    );
  }

  Widget _buildFeatureItem(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: R.height(4)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: R.width(4),
            color: const Color(0xFF7F67CB).withValues(alpha: 0.6),
          ),
          SizedBox(width: R.width(10)),
          Flexible(
            child: Text(
              text,
              style: AppTypography.bodyXxs.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ),
    );
  }
}
