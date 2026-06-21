import 'package:flutter_dotenv/flutter_dotenv.dart';

enum PetType { DOG, CAT }

class PetModel {
  final String id;
  final String name;
  final PetType type;
  final int? age;
  final String? breed;
  final String? imageUrl;
  final bool isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PetModel({
    required this.id,
    required this.name,
    required this.type,
    this.age,
    this.breed,
    this.imageUrl,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'],
      name: json['name'],
      type: json['type'] == 'DOG' ? PetType.DOG : PetType.CAT,
      age: json['age'],
      breed: json['breed'],
      imageUrl: json['imageUrl'],
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type == PetType.DOG ? 'DOG' : 'CAT',
      'age': age,
      'breed': breed,
      'imageUrl': imageUrl,
      'isDeleted': isDeleted,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get fullImageUrl => buildPetImageUrl(imageUrl);

  /// Builds an absolute image URL from a stored pet [imageUrl] value.
  /// Returns '' when empty; passes through asset and http(s) values; otherwise
  /// resolves a relative upload path against BASE_URL + /public (matches backend
  /// static serving and the existing training/emotions convention).
  static String buildPetImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return '';
    if (imageUrl.startsWith('assets/')) return imageUrl;
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    var cleanPath = imageUrl;
    if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);
    if (cleanPath.startsWith('public/')) cleanPath = cleanPath.substring(7);

    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    final cleanBaseUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    return '$cleanBaseUrl/public/$cleanPath';
  }

  PetModel copyWith({
    String? id,
    String? name,
    PetType? type,
    int? age,
    String? breed,
    String? imageUrl,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      imageUrl: imageUrl ?? this.imageUrl,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
