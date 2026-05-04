enum TrainingType { command, trick }

class TrainingItem {
  final String id;
  final String title;
  final String? imageUrl;
  final String category;
  final String position;
  final String command;
  final String guidance;
  final String confirmation;
  final bool isPremium;
  final int sortOrder;

  TrainingItem({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.category,
    required this.position,
    required this.command,
    required this.guidance,
    required this.confirmation,
    this.isPremium = false,
    this.sortOrder = 0,
  });

  factory TrainingItem.fromJson(Map<String, dynamic> json) {
    return TrainingItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'],
      category: json['category'] ?? '',
      position: json['position'] ?? '',
      command: json['command'] ?? '',
      guidance: json['guidance'] ?? '',
      confirmation: json['confirmation'] ?? '',
      isPremium: json['isPremium'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }

  // Helper for UI consistency
  String get name => title;
  String get imagePath => imageUrl ?? 'assets/images/play dog 1.png';
}
