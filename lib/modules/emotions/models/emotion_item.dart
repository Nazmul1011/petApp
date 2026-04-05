class EmotionItem {
  final String name;
  final String imagePath;
  final bool isLocked;

  EmotionItem({
    required this.name,
    required this.imagePath,
    this.isLocked = false,
  });
}
