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
        width: R.width(361),
        height: R.height(66),
        padding: EdgeInsets.symmetric(
          horizontal: R.width(16),
          vertical: R.height(6),
        ),
        margin: EdgeInsets.only(bottom: R.height(8)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(R.width(12)),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF9D6B) : Colors.black12,
            width: isSelected ? R.width(2.0) : R.width(1.0), // Stroke-md
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isSelected ? 0.05 : 0.02),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTypography.subtitleMd.copyWith(
                      color: AppColors.headingText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: R.height(2)),
                  Text(
                    subtitle,
                    style: AppTypography.bodySm.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (badgeText != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.width(10),
                      vertical: R.height(2),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F67CB),
                      borderRadius: BorderRadius.circular(R.width(8)),
                    ),
                    child: Text(
                      badgeText!,
                      style: AppTypography.bodyXxs.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 18),
                SizedBox(height: R.height(4)),
                Text(
                  rightText,
                  style: AppTypography.bodyXxs.copyWith(color: Colors.black38),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
