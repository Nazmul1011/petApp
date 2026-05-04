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
          2.5 // Sligthly thinner for grouped look
      ..strokeCap = StrokeCap.round;

    // Based on the image, we have groups of 5 bars
    // [small, medium, large, medium, small]
    const barsPerGroup = 5;
    final groupBaseHeights = [0.3, 0.6, 1.0, 0.6, 0.3];

    // Calculate how many groups can fit
    // Total bars = groups * barsPerGroup + spacing
    final numGroups = (values.length / barsPerGroup).floor();
    if (numGroups == 0) return;

    final totalBarsTotal = numGroups * barsPerGroup;
    final availableWidth = size.width;
    final barSpacing = availableWidth / (totalBarsTotal + (numGroups - 1) * 2);

    // Simulated split for purple/grey
    final splitGroupIndex = (numGroups * 0.4).floor();

    double currentX = 0;

    for (int g = 0; g < numGroups; g++) {
      // Color for the group
      paint.color = (secondaryColor != null && g > splitGroupIndex)
          ? secondaryColor!
          : color;

      for (int b = 0; b < barsPerGroup; b++) {
        final baseH = groupBaseHeights[b];

        // Add a bit of randomness/intensity from values[g * barsPerGroup + b]
        final intensity = values.length > (g * barsPerGroup + b)
            ? values[g * barsPerGroup + b]
            : 0.5;

        final height = baseH * intensity * size.height;

        final yStart = (size.height - height) / 2;
        final yEnd = yStart + height;

        canvas.drawLine(
          Offset(currentX, yStart),
          Offset(currentX, yEnd),
          paint,
        );
        currentX += barSpacing;
      }

      // Extra spacing between groups
      currentX += barSpacing * 1.5;
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) => true;
}
