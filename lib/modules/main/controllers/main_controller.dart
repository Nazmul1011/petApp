import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:petapp/core/controllers/base_controller.dart';
import 'package:petapp/modules/notification/controllers/notification_controller.dart';

class MainController extends GetxController
    with BaseController, WidgetsBindingObserver {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Load unread badge as soon as the main shell opens (post-login).
    _refreshNotifications();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshNotifications();
    }
  }

  void changeTabIndex(int index) {
    currentIndex.value = index;
    // Catch up the list/badge when opening the Notifications tab
    // (e.g. after a background push that couldn't update the UI).
    if (index == 4) {
      _refreshNotifications();
    }
  }

  void _refreshNotifications() {
    if (!Get.isRegistered<NotificationController>()) return;
    Get.find<NotificationController>().fetchNotifications(silent: true);
  }
}
