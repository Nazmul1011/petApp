import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:petapp/core/services/api_service.dart';
import 'package:petapp/modules/notification/controllers/notification_controller.dart';
import 'package:petapp/modules/notification/services/notification_api_service.dart';
import 'package:uuid/uuid.dart';

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const _deviceIdKey = 'device_game_id';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final NotificationApiService _notificationApi = NotificationApiService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GetStorage _storage = GetStorage();

  String? _currentToken;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _requestPermission();

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
    _messaging.onTokenRefresh.listen((_) => syncWithBackend());

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationOpen(initialMessage);
    }
  }

  Future<void> syncWithBackend() async {
    final accessToken = AuthTokenService().accessToken;
    if (accessToken == null || accessToken.isEmpty) return;

    try {
      final token = await _getFcmTokenWithRetry();
      if (token == null || token.isEmpty) return;

      _currentToken = token;
      final deviceId = await _getOrCreateDeviceId();
      final packageInfo = await PackageInfo.fromPlatform();

      await _notificationApi.registerPushToken(
        deviceId: deviceId,
        token: token,
        platform: _platformName(),
        appVersion: packageInfo.version,
      );
    } catch (e, stackTrace) {
      LoggerService().error('Failed to register push token', e, stackTrace);
    }
  }

  Future<String?> _getFcmTokenWithRetry() async {
    // iOS can throw `firebase_messaging/apns-token-not-set` shortly after install/open,
    // even if permissions are granted. A short retry window avoids failing registration.
    const maxAttempts = 5;

    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final token = await _messaging.getToken();
        if (token != null && token.isNotEmpty) return token;
      } catch (e) {
        final msg = e.toString();
        final isApnsNotReady = msg.contains('apns-token-not-set');
        if (!isApnsNotReady) rethrow;

        LoggerService().warn(
          'APNs token not ready yet (attempt $attempt/$maxAttempts). Retrying…',
        );
      }

      // Backoff: 0.5s, 1s, 2s, 3s, 5s
      final delayMs = switch (attempt) {
        1 => 500,
        2 => 1000,
        3 => 2000,
        4 => 3000,
        _ => 5000,
      };
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }

    return null;
  }

  Future<void> unregisterFromBackend() async {
    final token = _currentToken ?? await _messaging.getToken();
    if (token == null || token.isEmpty) return;

    try {
      await _notificationApi.unregisterPushToken(token: token);
    } catch (e, stackTrace) {
      LoggerService().error('Failed to unregister push token', e, stackTrace);
    } finally {
      _currentToken = null;
    }
  }

  Future<void> _requestPermission() async {
    try {
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
    } catch (e, stackTrace) {
      LoggerService().error('Push permission request failed', e, stackTrace);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    LoggerService().info(
      '[Push] Foreground message received: ${message.messageId}',
    );
    _applyIncomingPush(message);
  }

  void _handleNotificationOpen(RemoteMessage message) {
    LoggerService().info(
      '[Push] Notification opened: ${message.messageId}',
    );
    _applyIncomingPush(message);
  }

  void _applyIncomingPush(RemoteMessage message) {
    final controller = _ensureNotificationController();
    // Run after the current frame so GetX/UI listeners are ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.applyIncomingPush(message);
    });
  }

  NotificationController _ensureNotificationController() {
    if (Get.isRegistered<NotificationController>()) {
      return Get.find<NotificationController>();
    }
    return Get.put(NotificationController(), permanent: true);
  }

  Future<String> _getOrCreateDeviceId() async {
    String? deviceId = await _secureStorage.read(key: _deviceIdKey);
    deviceId ??= _storage.read<String>(_deviceIdKey);

    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await _secureStorage.write(key: _deviceIdKey, value: deviceId);
      _storage.write(_deviceIdKey, deviceId);
    }

    return deviceId;
  }

  String _platformName() {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return 'web';
  }
}
