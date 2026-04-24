class TranslationModel {
  final String id;
  final String userId;
  final String petId;
  final String sessionId;
  final String inputType; // TEXT | HUMAN_VOICE | PET_VOICE
  final String direction; // HUMAN_TO_PET | PET_TO_HUMAN
  final String? inputText;
  final String? inputAudioUrl;
  final String? outputText;
  final String? outputAudioUrl;
  final String status;
  final bool isSaved;
  final String? savedName;
  final DateTime? savedAt;
  final String? mood;
  final double? confidence;
  final DateTime createdAt;

  TranslationModel({
    required this.id,
    required this.userId,
    required this.petId,
    required this.sessionId,
    required this.inputType,
    required this.direction,
    this.inputText,
    this.inputAudioUrl,
    this.outputText,
    this.outputAudioUrl,
    required this.status,
    required this.isSaved,
    this.savedName,
    this.savedAt,
    this.mood,
    this.confidence,
    required this.createdAt,
  });

  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      petId: json['petId'] as String,
      sessionId: json['sessionId'] as String,
      inputType: json['inputType'] as String,
      direction: json['direction'] as String,
      inputText: json['inputText'] as String?,
      inputAudioUrl: json['inputAudioUrl'] as String?,
      outputText: json['outputText'] as String?,
      outputAudioUrl: json['outputAudioUrl'] as String?,
      status: json['status'] as String,
      isSaved: json['isSaved'] as bool? ?? false,
      savedName: json['savedName'] as String?,
      savedAt: json['savedAt'] != null
          ? DateTime.parse(json['savedAt'] as String)
          : null,
      mood: json['mood'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  bool get isHumanToPet => direction == 'HUMAN_TO_PET';
}
