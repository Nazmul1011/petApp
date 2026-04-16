class TalkSessionModel {
  final String id;
  final String userId;
  final String petId;
  final String status;
  final DateTime createdAt;

  TalkSessionModel({
    required this.id,
    required this.userId,
    required this.petId,
    required this.status,
    required this.createdAt,
  });

  factory TalkSessionModel.fromJson(Map<String, dynamic> json) {
    return TalkSessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      petId: json['petId'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
