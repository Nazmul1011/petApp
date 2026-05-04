class MoodDetectionItem {
  final String id;
  final String mood;
  final String detectedSound;
  final double confidence;
  final String? sourceAudioUrl;
  final DateTime createdAt;

  MoodDetectionItem({
    required this.id,
    required this.mood,
    required this.detectedSound,
    required this.confidence,
    this.sourceAudioUrl,
    required this.createdAt,
  });

  factory MoodDetectionItem.fromJson(Map<String, dynamic> json) {
    return MoodDetectionItem(
      id: json['id'] ?? '',
      mood: json['mood'] ?? 'NEUTRAL',
      detectedSound: json['detectedSound'] ?? 'Unknown sound',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      sourceAudioUrl: json['sourceAudioUrl'],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class MoodBreakdown {
  final String mood;
  final int count;
  final double percentage;
  final double averageConfidence;

  MoodBreakdown({
    required this.mood,
    required this.count,
    required this.percentage,
    required this.averageConfidence,
  });

  factory MoodBreakdown.fromJson(Map<String, dynamic> json) {
    return MoodBreakdown(
      mood: json['mood'] ?? 'NEUTRAL',
      count: json['count'] ?? 0,
      percentage: (json['percentage'] ?? 0.0).toDouble(),
      averageConfidence: (json['averageConfidence'] ?? 0.0).toDouble(),
    );
  }
}

class MoodPatterns {
  final String? dominantMood;
  final double averageConfidence;
  final List<dynamic> topDetectedSounds;

  MoodPatterns({
    this.dominantMood,
    required this.averageConfidence,
    required this.topDetectedSounds,
  });

  factory MoodPatterns.fromJson(Map<String, dynamic> json) {
    return MoodPatterns(
      dominantMood: json['dominantMood'],
      averageConfidence: (json['averageConfidence'] ?? 0.0).toDouble(),
      topDetectedSounds: json['topDetectedSounds'] ?? [],
    );
  }
}

class MoodAnalyticsResponse {
  final int total;
  final String filter;
  final List<MoodDetectionItem> items;
  final List<MoodBreakdown> breakdown;
  final MoodPatterns patterns;

  MoodAnalyticsResponse({
    required this.total,
    required this.filter,
    required this.items,
    required this.breakdown,
    required this.patterns,
  });

  factory MoodAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List?) ?? [];
    final items = itemsList
        .map((e) => MoodDetectionItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    final breakdownList = (stats['breakdown'] as List?) ?? [];
    final breakdown = breakdownList
        .map((e) => MoodBreakdown.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final patternsMap = stats['patterns'] as Map<String, dynamic>? ?? {};
    final patterns = MoodPatterns.fromJson(patternsMap);

    final pagination = json['pagination'] as Map<String, dynamic>? ?? {};

    return MoodAnalyticsResponse(
      total: pagination['total'] ?? 0,
      filter: pagination['filter'] ?? 'today',
      items: items,
      breakdown: breakdown,
      patterns: patterns,
    );
  }
}
