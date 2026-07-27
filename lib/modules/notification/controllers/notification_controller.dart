import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
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
  final RxInt unreadCount = 0.obs;

  /// Bumps whenever the inbox changes so list UIs always rebuild.
  final RxInt listVersion = 0.obs;

  Timer? _pollTimer;
  int _fetchGeneration = 0;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    _startPolling();
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    super.onClose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    // Fallback when FCM is delayed/missed (esp. background → foreground).
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      fetchNotifications(silent: true);
    });
  }

  Future<void> fetchNotifications({bool silent = false}) async {
    final generation = ++_fetchGeneration;
    try {
      if (!silent) setLoading(true);
      final result = await _apiService.listNotifications();
      if (generation != _fetchGeneration) return;

      result.items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      notifications.assignAll(result.items);
      unreadCount.value = result.unreadCount;
      _groupNotifications();
      listVersion.value++;
    } catch (e) {
      print('[NotificationController] Error: $e');
    } finally {
      if (!silent) setLoading(false);
    }
  }

  /// Instantly reflects a push in the inbox/badge, then syncs from the API.
  void applyIncomingPush(RemoteMessage message) {
    final title =
        message.notification?.title ??
        message.data['title'] ??
        'Notification';
    final body =
        message.notification?.body ??
        message.data['body'] ??
        message.data['message'] ??
        '';
    final remoteId = message.data['notificationId'];
    final id = (remoteId != null && remoteId.isNotEmpty)
        ? remoteId
        : 'push_${message.messageId ?? DateTime.now().millisecondsSinceEpoch}';

    final alreadyExists = notifications.any((n) => n.id == id);
    if (!alreadyExists && body.isNotEmpty) {
      final incoming = NotificationModel(
        id: id,
        userId: '',
        type: NotificationType.SYSTEM,
        title: title,
        message: body,
        data: Map<String, dynamic>.from(message.data),
        isRead: false,
        createdAt: DateTime.now(),
      );
      notifications.insert(0, incoming);
      unreadCount.value = unreadCount.value + 1;
      _groupNotifications();
      listVersion.value++;
    } else if (!alreadyExists) {
      unreadCount.value = unreadCount.value + 1;
    }

    // Sync from server with retries (covers race / missed payload fields).
    unawaited(_refreshWithRetries());
  }

  Future<void> _refreshWithRetries() async {
    const delays = <Duration>[
      Duration.zero,
      Duration(milliseconds: 600),
      Duration(milliseconds: 1500),
      Duration(seconds: 3),
    ];

    for (final delay in delays) {
      if (delay > Duration.zero) {
        await Future<void>.delayed(delay);
      }
      await fetchNotifications(silent: true);
    }
  }

  void _syncUnreadFromLocal() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
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
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !notifications[index].isRead) {
      notifications[index] = notifications[index].copyWith(isRead: true);
      _groupNotifications();
      _syncUnreadFromLocal();
      listVersion.value++;
    }

    final serverUnread = await _apiService.markRead([id]);
    if (serverUnread != null) {
      unreadCount.value = serverUnread;
    }
  }

  Future<void> markAllAsRead() async {
    final unreadIds = notifications
        .where((n) => !n.isRead)
        .map((n) => n.id)
        .toList();

    if (unreadIds.isNotEmpty) {
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].isRead) {
          notifications[i] = notifications[i].copyWith(isRead: true);
        }
      }
      _groupNotifications();
      unreadCount.value = 0;
      listVersion.value++;

      final serverUnread = await _apiService.markRead(unreadIds);
      if (serverUnread != null) {
        unreadCount.value = serverUnread;
      }
    }
  }
}
