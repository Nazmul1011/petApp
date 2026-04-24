import 'dart:convert';

enum NotificationType { MOOD_ALERT, TRAINING_REMINDER, SUBSCRIPTION, SYSTEM }

class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['userId'],
      type: _typeFromString(json['type']),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      data: json['data'] is String ? jsonDecode(json['data']) : json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  static NotificationType _typeFromString(String? type) {
    switch (type) {
      case 'MOOD_ALERT':
        return NotificationType.MOOD_ALERT;
      case 'TRAINING_REMINDER':
        return NotificationType.TRAINING_REMINDER;
      case 'SUBSCRIPTION':
        return NotificationType.SUBSCRIPTION;
      default:
        return NotificationType.SYSTEM;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
