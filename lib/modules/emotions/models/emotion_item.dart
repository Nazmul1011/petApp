import 'package:flutter_dotenv/flutter_dotenv.dart';

class EmotionItem {
  final String id;
  final String name;
  final String? audioUrl;
  final String imagePath;
  final bool isPremium;
  final bool isLocked;

  EmotionItem({
    required this.id,
    required this.name,
    required this.imagePath,
    this.audioUrl,
    this.isPremium = false,
    this.isLocked = false,
  });

  factory EmotionItem.fromJson(
    Map<String, dynamic> json, {
    bool isLocked = false,
  }) {
    String imagePathValue = '';
    final imageUrl = json['imageUrl'] as String?;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      if (imageUrl.startsWith('http')) {
        imagePathValue = imageUrl;
      } else {
        final baseUrl = dotenv.env['BASE_URL'] ?? '';
        final cleanBaseUrl = baseUrl.endsWith('/')
            ? baseUrl.substring(0, baseUrl.length - 1)
            : baseUrl;
        final cleanImageUrl = imageUrl.startsWith('/') ? imageUrl : '/public/$imageUrl';
        imagePathValue = '$cleanBaseUrl$cleanImageUrl';
      }
    } else {
      imagePathValue = _getMoodImage(json['name']);
    }

    return EmotionItem(
      id: json['id'],
      name: json['name'],
      audioUrl: json['audioUrl'],
      imagePath: imagePathValue,
      isPremium: json['isPremium'] ?? false,
      isLocked: isLocked,
    );
  }

  static String _getMoodImage(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('anxious') || lowerName.contains('scared')) {
      return 'assets/images/anxious dog 1.png';
    } else if (lowerName.contains('hungry') || lowerName.contains('yum')) {
      return 'assets/images/hungry dog 1.png';
    } else if (lowerName.contains('play') || lowerName.contains('happy')) {
      return 'assets/images/play dog 1.png';
    }
    return 'assets/images/dog_happy_face.webp';
  }
}
