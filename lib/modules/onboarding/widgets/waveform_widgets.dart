import 'dart:math';
import 'package:flutter/material.dart';

class SoundWavePainter extends CustomPainter {
  final Color color;
  final double animationValue;

  SoundWavePainter({required this.color, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: (1.0 - animationValue).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final center = Offset(0, size.height / 2);

    // Draw 3 expanding arcs to simulate sound waves
    for (int i = 1; i <= 3; i++) {
      final currentRadius =
          (size.width * 0.3 * i) + (size.width * 0.4 * animationValue);
      final rect = Rect.fromCircle(center: center, radius: currentRadius);

      canvas.drawArc(
        rect,
        -pi / 4, // Start angle
        pi / 2, // Sweep angle
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SoundWavePainter oldDelegate) =>
      oldDelegate.animationValue != animationValue;
}

class WaveformPainter extends CustomPainter {
  final List<double> values;
  final Color color;
  final Color? secondaryColor;

  WaveformPainter({
    required this.values,
    required this.color,
    this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth =
          3.0 // Bolder premium line weight
      ..strokeCap = StrokeCap.round;

    final totalBars = values.length;
    if (totalBars == 0) return;

    // Visual padding on both left and right inside the pill container
    const horizontalPadding = 16.0;
    final paintWidth = size.width - (2 * horizontalPadding);

    // Spacing between consecutive bars
    final barSpacing = totalBars > 1
        ? paintWidth / (totalBars - 1)
        : paintWidth;

    // Split index for the colored vs grey visual effect (40% colored)
    final splitIndex = (totalBars * 0.4).floor();

    for (int i = 0; i < totalBars; i++) {
      // Color transition (e.g. first 40% colored, remaining secondary)
      paint.color = (secondaryColor != null && i > splitIndex)
          ? secondaryColor!
          : color;

      final intensity = values[i];
      // Calculate height with standard vertical bounds and a nice minimum baseline
      final height = (intensity * size.height * 0.75).clamp(
        6.0,
        size.height * 0.75,
      );

      final yStart = (size.height - height) / 2;
      final yEnd = yStart + height;
      final xPos = horizontalPadding + (i * barSpacing);

      canvas.drawLine(Offset(xPos, yStart), Offset(xPos, yEnd), paint);
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) => true;
}
