import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String rightText;
  final String? badgeText;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? rightTextColor;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rightText,
    this.badgeText,
    required this.isSelected,
    required this.onTap,
    this.rightTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: R.width(350),
        height: R.height(78),
        padding: EdgeInsets.symmetric(
          horizontal: R.width(18),
          vertical: R.height(10),
        ),
        margin: EdgeInsets.only(bottom: R.height(8)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.width(12)),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.black12,
            width: R.width(1.0), // Stroke-sm
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.05 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.subtitleMd.copyWith(
                      color: AppColors.headingText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (badgeText != null) ...[
                  SizedBox(width: R.width(8)),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.width(12),
                      vertical: R.height(4),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(R.width(12)),
                    ),
                    child: Text(
                      badgeText!,
                      style: AppTypography.bodyXxs.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: R.height(4)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 0,
                  child: Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.textSoft,
                    ),
                  ),
                ),
                SizedBox(width: R.width(8)),
                Expanded(
                  child: Text(
                    rightText,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyXxs.copyWith(
                      color: rightTextColor ?? AppColors.textSoft,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
