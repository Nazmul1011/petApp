import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/core/services/api_service.dart';
import 'package:petapp/shared/widgets/snack_bar/app_snack_bar.dart';
import '../models/emotion_item.dart';

class EmotionsController extends GetxController with BaseController {
  final _apiService = ApiService();

  final emotions = <EmotionItem>[
    EmotionItem(name: "Happy", imagePath: "assets/images/dog_happy_face.png"),
    EmotionItem(name: "Attention", imagePath: "assets/images/dog_happy_face.png"),
    EmotionItem(name: "Angry", imagePath: "assets/images/dog_happy_face.png"),
    EmotionItem(name: "Neutral", imagePath: "assets/images/dog_happy_face.png"),
    EmotionItem(name: "Love", imagePath: "assets/images/dog_happy_face.png", isLocked: true),
    EmotionItem(name: "Sleep", imagePath: "assets/images/dog_happy_face.png", isLocked: true),
    EmotionItem(name: "Grumpy", imagePath: "assets/images/dog_happy_face.png"),
    EmotionItem(name: "Scared", imagePath: "assets/images/dog_happy_face.png"),
    EmotionItem(name: "Walking", imagePath: "assets/images/dog_happy_face.png"),
    EmotionItem(name: "Yum", imagePath: "assets/images/dog_happy_face.png"),
    EmotionItem(name: "Sorry", imagePath: "assets/images/dog_happy_face.png"),
    EmotionItem(name: "Anxious", imagePath: "assets/images/dog_happy_face.png"),
  ].obs;

  String _mapToBackendMoodType(String emotionName) {
    switch (emotionName.toLowerCase()) {
      case 'happy':
        return 'EXCITED'; // Or PLAYFUL
      case 'attention':
        return 'CALM';
      case 'angry':
      case 'grumpy':
        return 'ANGRY';
      case 'neutral':
        return 'NEUTRAL';
      case 'love':
        return 'EXCITED';
      case 'sleep':
        return 'SLEEPY';
      case 'scared':
      case 'sorry':
      case 'anxious':
        return 'ANXIOUS';
      case 'walking':
        return 'PLAYFUL';
      case 'yum':
        return 'HUNGRY';
      default:
        return 'NEUTRAL';
    }
  }

  Future<void> selectEmotion(EmotionItem item) async {
    if (item.isLocked) {
      Get.snackbar("Locked", "This emotion is currently locked.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      setLoading(true);
      final moodType = _mapToBackendMoodType(item.name);
      
      final payload = {
        "mood": moodType,
        "detectedSound": item.name,
        "confidence": 0.85 // Default mock confidence
      };

      final response = await _apiService.post(
        '/mood',
        data: payload,
      );

      setLoading(false);

      if (response.statusCode == 201 || response.statusCode == 200) {
        showSnack(
          content: '${item.name} emotion recorded securely!',
          status: SnackBarStatus.success,
        );
      }
    } catch (e) {
      setLoading(false);
      showSnack(
        content: e.toString(),
        status: SnackBarStatus.error,
      );
    }
  }
}
