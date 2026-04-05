import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/core/routes/app_routes.dart';
import '../models/training_item.dart';

class TrainingController extends GetxController with BaseController {
  final basicCommands = <TrainingItem>[
    TrainingItem(name: "Sit", imagePath: "assets/images/dog_happy_face.png", type: TrainingType.command),
    TrainingItem(name: "Stay", imagePath: "assets/images/dog_happy_face.png", type: TrainingType.command),
    TrainingItem(name: "Go outside", imagePath: "assets/images/dog_happy_face.png", type: TrainingType.command, isLocked: true),
    TrainingItem(name: "Drop it/Stop", imagePath: "assets/images/dog_happy_face.png", type: TrainingType.command, isLocked: true),
    TrainingItem(name: "Stand", imagePath: "assets/images/dog_happy_face.png", type: TrainingType.command, isLocked: true),
    TrainingItem(name: "Come", imagePath: "assets/images/dog_happy_face.png", type: TrainingType.command, isLocked: true),
  ].obs;

  final tricks = <TrainingItem>[
    TrainingItem(name: "Cup game", imagePath: "assets/images/dog_happy_face.png", type: TrainingType.trick, isLocked: true),
    TrainingItem(name: "Give paw", imagePath: "assets/images/dog_happy_face.png", type: TrainingType.trick, isLocked: true),
    TrainingItem(name: "Bark", imagePath: "assets/images/dog_happy_face.png", type: TrainingType.trick, isLocked: true),
    TrainingItem(name: "Sit", imagePath: "assets/images/dog_happy_face.png", type: TrainingType.trick),
    TrainingItem(name: "Turn Around", imagePath: "assets/images/dog_happy_face.png", type: TrainingType.trick),
    TrainingItem(name: "Search", imagePath: "assets/images/dog_happy_face.png", type: TrainingType.trick),
  ].obs;

  void goToDetail(TrainingItem item) {
    if (item.isLocked) {
      Get.snackbar("Locked", "This training is currently locked.", snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.toNamed(AppRoutes.trainingDetail, arguments: item);
    }
  }

  void goToViewAll(String category) {
    Get.toNamed(AppRoutes.trainingViewAll, arguments: category);
  }

  Map<String, String> getTrainingData(String commandName) {
    // For now, same text for all as per user request
    return {
      "Position": "Place the dog standing in front of you. Keep the environment quiet with minimal distractions. A leash may be used for control but is not required.",
      "Command": "Say the word “$commandName” once in a clear, calm voice. Do not repeat the command. Consistency of the word matters more than volume.",
      "Guidance": "Hold a treat close to the dog’s nose, then slowly move it upward and slightly backward over the head. As the head lifts, the dog’s hips naturally lower into a $commandName position.",
      "Confirmation": "The moment the dog’s hips touch the ground, clearly say “Good” or another confirmation word to mark the success.",
    };
  }
}
