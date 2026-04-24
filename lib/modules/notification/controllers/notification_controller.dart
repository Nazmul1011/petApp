import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import '../models/notification_model.dart';
import '../services/notification_api_service.dart';

class NotificationController extends GetxController with BaseController {
  final NotificationApiService _apiService = NotificationApiService();

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxList<NotificationModel> todayNotifications =
      <NotificationModel>[].obs;
  final RxList<NotificationModel> previousNotifications =
      <NotificationModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      setLoading(true);
      final list = await _apiService.listNotifications();
      // Sort by newest first
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifications.assignAll(list);
      _groupNotifications();
    } catch (e) {
      print('[NotificationController] Error: $e');
    } finally {
      setLoading(false);
    }
  }

  void _groupNotifications() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    todayNotifications.assignAll(
      notifications.where((n) {
        final date = DateTime(
          n.createdAt.year,
          n.createdAt.month,
          n.createdAt.day,
        );
        return date.isAtSameMomentAs(todayStart);
      }).toList(),
    );

    previousNotifications.assignAll(
      notifications.where((n) {
        final date = DateTime(
          n.createdAt.year,
          n.createdAt.month,
          n.createdAt.day,
        );
        return date.isBefore(todayStart);
      }).toList(),
    );
  }

  Future<void> markAsRead(String id) async {
    // Optimistic Update: Update local state immediately
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _groupNotifications();
    }

    // Background API call
    await _apiService.markRead([id]);
  }

  Future<void> markAllAsRead() async {
    final unreadIds = notifications
        .where((n) => !n.isRead)
        .map((n) => n.id)
        .toList();

    if (unreadIds.isNotEmpty) {
      // Optimistic Update: Update all local state
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = notifications[i].copyWith(isRead: true);
        }
      }
      _groupNotifications();

      // Background API call
      await _apiService.markRead(unreadIds);
    }
  }
}
