import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class LanguageItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String flagAsset;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.flagAsset,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: R.height(12)),
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Flag Display
            Container(
              width: R.width(40),
              height: R.width(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withValues(alpha: 0.1),
              ),
              clipBehavior: Clip.antiAlias,
              child: SvgPicture.asset(flagAsset, fit: BoxFit.cover),
            ),
            SizedBox(width: R.width(16)),

            // Text Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTypography.subtitleSm.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: R.height(2)),
                  Text(
                    subtitle,
                    style: AppTypography.bodyXxs.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),

            // Custom Radio Button
            Container(
              width: R.width(20),
              height: R.width(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF7F67CB) : Colors.grey,
                  width: isSelected ? R.width(2.0) : R.width(1.0),
                ),
                color: Colors.white,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: R.width(10),
                        height: R.width(10),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFF7F67CB),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
