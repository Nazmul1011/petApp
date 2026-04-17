
enum AppLanguage {
  enUk,
  enUs,
  bn,
  de,
  fr,
  es,
  it,
}

class UserModel {
  final String id;
  final String gameId;
  final AppLanguage language;
  final bool onboardingCompleted;
  final int onboardingStep;
  final String? activePetId;
  final String? pushToken;
  final List<dynamic> subscriptions;
  final List<dynamic> pets;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.gameId,
    required this.language,
    required this.onboardingCompleted,
    required this.onboardingStep,
    this.activePetId,
    this.pushToken,
    this.subscriptions = const [],
    this.pets = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPremium => subscriptions.isNotEmpty;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      gameId: json['gameId'],
      language: AppLanguage.values.firstWhere(
        (e) => e.toString().split('.').last == json['language'],
        orElse: () => AppLanguage.enUk,
      ),
      onboardingCompleted: json['onboardingCompleted'] ?? false,
      onboardingStep: json['onboardingStep'] ?? 0,
      activePetId: json['activePetId'],
      pushToken: json['pushToken'],
      subscriptions: json['subscriptions'] ?? [],
      pets: json['pets'] ?? [],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'gameId': gameId,
      'language': language.toString().split('.').last,
      'onboardingCompleted': onboardingCompleted,
      'onboardingStep': onboardingStep,
      'activePetId': activePetId,
      'pushToken': pushToken,
      'subscriptions': subscriptions,
      'pets': pets,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
