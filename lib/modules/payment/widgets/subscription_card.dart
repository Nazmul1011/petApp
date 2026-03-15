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

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.rightText,
    this.badgeText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: EdgeInsets.symmetric(
            horizontal: R.width(16), vertical: R.height(16)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.width(16)),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9D6B) : Colors.transparent, // Peach/orange selection border
            width: isSelected ? R.width(1.5) : 0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.08 : 0.04),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.subtitleSm.copyWith(
                      color: AppColors.headingText,
                    ),
                  ),
                  SizedBox(height: R.height(4)),
                  Text(
                    subtitle,
                    style: AppTypography.bodyXs.copyWith(
                      color: AppColors.bodyText,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (badgeText != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: R.width(10), vertical: R.height(4)),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(R.width(20)),
                    ),
                    child: Text(
                      badgeText!,
                      style: AppTypography.bodyXxs.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  )
                else
                  SizedBox(height: R.height(20)), // Space placeholder
                SizedBox(height: R.height(8)),
                Text(
                  rightText,
                  style: AppTypography.bodyXxs.copyWith(
                    color: const Color(0xFFA1A1A1),
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
