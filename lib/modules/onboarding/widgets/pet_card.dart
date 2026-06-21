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
  final double? gapAngle;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 2,
    this.dashWidth = 5,
    this.dashSpace = 5,
    this.gapAngle,
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
    // Round (not floor) so the dashes divide the circle evenly and the
    // pattern closes perfectly at angle 0 instead of leaving a leftover gap.
    final dashCount = (circumference / (dashWidth + dashSpace)).round();
    final period = (2 * pi) / dashCount;
    final sweepAngle = (dashWidth / circumference) * 2 * pi;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * period;

      if (gapAngle != null) {
        final angle = startAngle % (2 * pi);
        final gapStart = pi / 2 - gapAngle!;
        final gapEnd = pi / 2 + gapAngle!;
        if (angle > gapStart && angle < gapEnd) {
          continue;
        }
      }

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
  bool shouldRepaint(covariant DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.gapAngle != gapAngle;
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
    final themeColor = isSelected ? AppColors.primaryColor : const Color(0xFFE0E0E0);
    final double diameter = R.width(140);
    final double radius = diameter / 2;
    final double cx = radius;
    final double cy = radius;
    
    // The angle in radians for the gap at the bottom of the dashed circle
    const double gapAngle = 0.54; 
    
    // Left dot center coordinates relative to the 140x140 container
    final double leftDotX = cx - radius * sin(gapAngle);
    final double leftDotY = cy + radius * cos(gapAngle);
    
    // Right dot center coordinates relative to the 140x140 container
    final double rightDotX = cx + radius * sin(gapAngle);
    final double rightDotY = cy + radius * cos(gapAngle);

    final double dotDiameter = R.width(8);
    final double dotRadius = dotDiameter / 2;
    final double badgeHeight = R.width(26);

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: R.width(160),
        height: R.height(165),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Container Stack of size 140x140 to coordinate all graphics
            SizedBox(
              width: diameter,
              height: diameter,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: diameter,
                    height: diameter,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? const Color(0xFFEBE6FF)
                          : Colors.white,
                    ),
                  ),
                  // Dashed border (always visible)
                  CustomPaint(
                    size: Size(diameter, diameter),
                    painter: DashedCirclePainter(
                      color: themeColor,
                      strokeWidth: 1.5,
                      dashWidth: 4,
                      dashSpace: 4,
                      gapAngle: gapAngle,
                    ),
                  ),
                  // Pet image with pop-out scale animation
                  Positioned.fill(
                    child: Center(
                      child: AnimatedScale(
                        scale: isSelected ? 1.15 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        child: Image.asset(
                          imagePath,
                          width: R.width(95),
                          height: R.width(95),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  // The Badge (pill) spanning from leftDotX to rightDotX
                  Positioned(
                    left: leftDotX,
                    right: diameter - rightDotX,
                    top: leftDotY - badgeHeight / 2,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: badgeHeight,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(badgeHeight / 2),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isSelected ? 0.15 : 0.02),
                            blurRadius: isSelected ? 8 : 4,
                            offset: isSelected ? const Offset(0, 4) : Offset.zero,
                          ),
                        ],
                      ),
                      child: Text(
                        label.toUpperCase(),
                        style: AppTypography.labelXs.copyWith(
                          color: isSelected ? Colors.white : Colors.grey.shade500,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Left Dot overlapping the left boundary of the badge
                  Positioned(
                    left: leftDotX - dotRadius,
                    top: leftDotY - dotRadius,
                    child: Container(
                      width: dotDiameter,
                      height: dotDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeColor,
                      ),
                    ),
                  ),
                  // Right Dot overlapping the right boundary of the badge
                  Positioned(
                    left: rightDotX - dotRadius,
                    top: rightDotY - dotRadius,
                    child: Container(
                      width: dotDiameter,
                      height: dotDiameter,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: themeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
