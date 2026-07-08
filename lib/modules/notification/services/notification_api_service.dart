import 'package:petapp/core/services/api_service.dart';
import '../models/notification_model.dart';

class NotificationApiService {
  final ApiService _apiService = ApiService();

  Future<List<NotificationModel>> listNotifications() async {
    try {
      final response = await _apiService.get('/notifications');
      final raw = response.data;

      // Handle the paginated response format: { success: true, data: { items: [...] } }
      final data = (raw is Map && raw.containsKey('data')) ? raw['data'] : raw;

      List<dynamic> items = [];
      if (data is Map && data.containsKey('items')) {
        items = data['items'] as List<dynamic>;
      } else if (data is List) {
        items = data;
      }

      return items
          .map(
            (e) =>
                NotificationModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (e) {
      print('[NotificationApiService] listNotifications error: $e');
    }
    return [];
  }

  Future<bool> markRead(List<String> notificationIds) async {
    try {
      final response = await _apiService.patch(
        '/notifications/read',
        data: {'ids': notificationIds},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[NotificationApiService] markRead error: $e');
      return false;
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
