import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import '../controllers/mood_history_controller.dart';
import '../models/mood_analytics_model.dart';
import 'dart:math';

class MoodHistoryView extends StatelessWidget {
  const MoodHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MoodHistoryController());

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabs(controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7F67CB)),
                  );
                }
                final data = controller.analyticsData.value;
                if (data == null || data.items.isEmpty) {
                  return const Center(child: Text('No mood history available.'));
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: R.width(20),
                    vertical: R.height(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimeline(data.items),
                      SizedBox(height: R.height(30)),
                      const Text(
                        'Mood breakdown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: R.height(16)),
                      _buildBreakdown(data.breakdown),
                      SizedBox(height: R.height(30)),
                      const Text(
                        'Patterns we noticed',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: R.height(16)),
                      _buildPatterns(data),
                      SizedBox(height: R.height(40)),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(
        left: R.width(16),
        right: R.width(16),
        top: R.height(8),
        bottom: R.height(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
          ),
          SizedBox(height: R.height(16)),
          const Text(
            'Mood history',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(MoodHistoryController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: R.width(16)),
      child: Row(
        children: [
          _buildTab(controller, 'Today', 'today'),
          SizedBox(width: R.width(10)),
          _buildTab(controller, '7 Days', '7d'),
          SizedBox(width: R.width(10)),
          _buildTab(controller, '30 Days', '30d'),
        ],
      ),
    );
  }

  Widget _buildTab(MoodHistoryController controller, String label, String value) {
    return Obx(() {
      final isSelected = controller.selectedFilter.value == value;
      return GestureDetector(
        onTap: () => controller.setFilter(value),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: R.width(16),
            vertical: R.height(8),
          ),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF8A72D6) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isSelected
                ? null
                : Border.all(color: Colors.grey.shade200),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTimeline(List<MoodDetectionItem> items) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isLast = index == items.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 30,
                child: CustomPaint(
                  painter: _TimelinePainter(
                    color: _MoodColors.getColor(item.mood),
                    isLast: isLast,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : R.height(16)),
                  child: _buildTimelineCard(item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimelineCard(MoodDetectionItem item) {
    final color = _MoodColors.getColor(item.mood);
    final bgColor = color.withOpacity(0.1);

    // Format time roughly for display (e.g. 10:42 AM)
    final timeStr = "${item.createdAt.hour > 12 ? item.createdAt.hour - 12 : (item.createdAt.hour == 0 ? 12 : item.createdAt.hour)}:${item.createdAt.minute.toString().padLeft(2, '0')} ${item.createdAt.hour >= 12 ? 'PM' : 'AM'}";

    return Container(
      padding: EdgeInsets.all(R.width(16)),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.mood.capitalizeFirst ?? item.mood,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                timeStr,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          SizedBox(height: R.height(12)),
          Divider(color: color.withOpacity(0.2), height: 1),
          SizedBox(height: R.height(12)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Detected sound', style: TextStyle(fontSize: 13, color: Colors.black87)),
              Text(item.detectedSound, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
          SizedBox(height: R.height(6)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Confidence', style: TextStyle(fontSize: 13, color: Colors.black87)),
              Text('${(item.confidence * 100).toInt()}%', style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown(List<MoodBreakdown> breakdown) {
    return Container(
      padding: EdgeInsets.all(R.width(20)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: breakdown.map((item) {
                final color = _MoodColors.getColor(item.mood);
                return Padding(
                  padding: EdgeInsets.only(bottom: R.height(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.mood.capitalizeFirst ?? item.mood,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${item.percentage.toInt()}%',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(width: R.width(20)),
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: 1,
              child: CustomPaint(
                painter: _DonutChartPainter(breakdown),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatterns(MoodAnalyticsResponse data) {
    // Generate simple patterns based on the data.
    List<Widget> patternCards = [];

    if (data.patterns.dominantMood != null) {
      final domMood = data.patterns.dominantMood!;
      final color = _MoodColors.getColor(domMood);
      patternCards.add(
        _buildPatternCard(
          color,
          'Your pet mostly feels ${domMood.toLowerCase()} recently. ${data.patterns.topDetectedSounds.isNotEmpty ? "Common sound: ${data.patterns.topDetectedSounds.first['sound']}." : ""}',
        ),
      );
    }

    if (data.breakdown.any((element) => element.mood == 'ANXIOUS' && element.percentage > 10)) {
      final color = _MoodColors.getColor('ANXIOUS');
      patternCards.add(
        _buildPatternCard(
          color,
          'Anxious signals appeared more often this period. Consider checking for environmental changes.',
        ),
      );
    }
    
    if (data.breakdown.any((element) => element.mood == 'HUNGRY' && element.percentage > 15)) {
      final color = _MoodColors.getColor('HUNGRY');
      patternCards.add(
        _buildPatternCard(
          color,
          'Hunger-related sounds are consistent. This pattern has been stable.',
        ),
      );
    }

    if (patternCards.isEmpty) {
      patternCards.add(const Text('Not enough data to find patterns.'));
    }

    return Column(
      children: patternCards,
    );
  }

  Widget _buildPatternCard(Color color, String text) {
    return Container(
      margin: EdgeInsets.only(bottom: R.height(12)),
      padding: EdgeInsets.all(R.width(16)),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
      ),
    );
  }
}

class _TimelinePainter extends CustomPainter {
  final Color color;
  final bool isLast;

  _TimelinePainter({required this.color, required this.isLast});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Draw the circle
    canvas.drawCircle(Offset(size.width / 2, 24), 6, paint);

    // Draw dashed line below the circle if not last
    if (!isLast) {
      final linePaint = Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      double startY = 38;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(size.width / 2, startY),
          Offset(size.width / 2, startY + 4),
          linePaint,
        );
        startY += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DonutChartPainter extends CustomPainter {
  final List<MoodBreakdown> breakdown;

  _DonutChartPainter(this.breakdown);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    final strokeWidth = radius * 0.4;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    double startAngle = -pi / 2;

    for (final item in breakdown) {
      final sweepAngle = (item.percentage / 100) * 2 * pi;
      final paint = Paint()
        ..color = _MoodColors.getColor(item.mood)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      
      // Draw small gap
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _MoodColors {
  static Color getColor(String mood) {
    switch (mood.toUpperCase()) {
      case 'PLAYFUL':
      case 'EXCITED':
        return const Color(0xFF1ABC9C); // Teal/Green
      case 'HUNGRY':
        return const Color(0xFFF39C12); // Orange
      case 'CALM':
        return const Color(0xFF3498DB); // Blue
      case 'ANXIOUS':
      case 'ANGRY':
        return const Color(0xFFE74C3C); // Red
      case 'SLEEPY':
        return const Color(0xFF9B59B6); // Purple
      default:
        return Colors.grey;
    }
  }
}
