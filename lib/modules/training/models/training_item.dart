enum TrainingType { command, trick }

class TrainingItem {
  final String name;
  final String imagePath;
  final bool isLocked;
  final TrainingType type;

  TrainingItem({
    required this.name,
    required this.imagePath,
    this.isLocked = false,
    required this.type,
  });
}
