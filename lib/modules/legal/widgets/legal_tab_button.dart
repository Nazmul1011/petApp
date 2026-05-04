import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class LegalTabButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const LegalTabButton({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: R.width(16),
          vertical: R.height(8),
        ),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7F67CB) : Colors.transparent,
          borderRadius: BorderRadius.circular(R.width(20)),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7F67CB)
                : Colors.grey.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          title,
          style: AppTypography.subtitleSm.copyWith(
            color: isSelected ? Colors.white : AppColors.headingText,
          ),
        ),
      ),
    );
  }
}
