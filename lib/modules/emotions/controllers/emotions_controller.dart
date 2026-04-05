import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import '../models/emotion_item.dart';

class EmotionsController extends GetxController with BaseController {
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

  void selectEmotion(EmotionItem item) {
    if (item.isLocked) {
      Get.snackbar("Locked", "This emotion is currently locked.",
          snackPosition: SnackPosition.BOTTOM);
    } else {
      // Handle emotion selection
    }
  }
}
