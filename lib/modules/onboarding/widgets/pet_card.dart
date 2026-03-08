import 'dart:math';
import 'package:flutter/material.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/modules/onboarding/controllers/onboarding_controller.dart';
import 'package:petapp/shared/helpers/responsive.dart';

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashWidth = 5,
    this.dashSpace = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final circumference = 2 * pi * radius;
    final dashCount = (circumference / (dashWidth + dashSpace)).floor();

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashWidth + dashSpace) / circumference) * 2 * pi;
      final sweepAngle = (dashWidth / circumference) * 2 * pi;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PetCard extends StatelessWidget {
  final PetType type;
  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const PetCard({
    super.key,
    required this.type,
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Dashed border (only visible when selected)
              if (isSelected)
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 300),
                  builder: (context, value, child) {
                    return CustomPaint(
                      size: Size(R.width(150), R.width(150)),
                      painter: DashedCirclePainter(
                        color: AppColors.primaryColor.withValues(alpha: value),
                        strokeWidth: 2,
                      ),
                    );
                  },
                ),
              // Background circle
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: R.width(140),
                height: R.width(140),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFFEBE6FF)
                      : const Color(0xFFF5F5F5),
                ),
              ),
              // Pet image with pop-out scale animation
              AnimatedScale(
                scale: isSelected ? 1.15 : 1.0, // "Medium" scale pop out
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                child: Image.asset(
                  imagePath,
                  width: R.width(90),
                  height: R.width(90),
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
          SizedBox(height: R.height(12)),
          // Label pill
          AnimatedContainer(
            duration: const Duration(milliseconds: 1000),
            padding: EdgeInsets.symmetric(
              horizontal: R.width(16),
              vertical: R.height(6),
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(R.width(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Text(
              label,
              style: AppTypography.labelMd.copyWith(
                color: isSelected ? Colors.white : AppColors.bodyText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
