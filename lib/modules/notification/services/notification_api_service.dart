import 'package:petapp/core/services/api_service.dart';
import '../models/notification_model.dart';

class NotificationListResult {
  const NotificationListResult({
    required this.items,
    required this.unreadCount,
  });

  final List<NotificationModel> items;
  final int unreadCount;
}

class NotificationApiService {
  final ApiService _apiService = ApiService();

  Future<NotificationListResult> listNotifications() async {
    final response = await _apiService.get('/notifications');
    final raw = response.data;

    // Handle the paginated response format: { success: true, data: { items: [...] } }
    final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;

    List<dynamic> items = [];
    var unreadCount = 0;

    if (data is Map) {
      if (data.containsKey('items')) {
        items = data['items'] as List<dynamic>;
      }
      final rawUnread = data['unreadCount'];
      if (rawUnread is int) {
        unreadCount = rawUnread;
      } else if (rawUnread is num) {
        unreadCount = rawUnread.toInt();
      }
    } else if (data is List) {
      items = data;
    }

    final parsed = items
        .map(
          (e) =>
              NotificationModel.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();

    if (data is! Map || !data.containsKey('unreadCount')) {
      unreadCount = parsed.where((n) => !n.isRead).length;
    }

    return NotificationListResult(items: parsed, unreadCount: unreadCount);
  }

  Future<int?> markRead(List<String> notificationIds) async {
    try {
      final response = await _apiService.patch(
        '/notifications/read',
        data: {'ids': notificationIds},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        return null;
      }

      final raw = response.data;
      final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;
      if (data is Map && data['unreadCount'] != null) {
        final rawUnread = data['unreadCount'];
        if (rawUnread is int) return rawUnread;
        if (rawUnread is num) return rawUnread.toInt();
      }
      return null;
    } catch (e) {
      print('[NotificationApiService] markRead error: $e');
      return null;
    }
  }

  Future<bool> registerPushToken({
    required String deviceId,
    required String token,
    required String platform,
    String? appVersion,
  }) async {
    try {
      final response = await _apiService.post(
        '/notifications/push-token',
        data: {
          'deviceId': deviceId,
          'token': token,
          'platform': platform,
          if (appVersion != null) 'appVersion': appVersion,
        },
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('[NotificationApiService] registerPushToken error: $e');
      return false;
    }
  }

  Future<bool> unregisterPushToken({required String token}) async {
    try {
      final response = await _apiService.delete(
        '/notifications/push-token',
        data: {'token': token},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[NotificationApiService] unregisterPushToken error: $e');
      return false;
    }
  }
}
