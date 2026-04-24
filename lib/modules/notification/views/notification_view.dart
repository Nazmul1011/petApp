import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/widgets/app_header.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      horizontalPadding: 0,
      body: Column(
        children: [
          const AppHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: R.width(20),
                      vertical: R.height(16),
                    ),
                    child: Text(
                      "Notifications",
                      style: AppTypography.h5.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Expanded(
                    child: controller.notifications.isEmpty
                        ? _buildEmptyState()
                        : _buildNotificationList(),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: R.width(64), color: Colors.grey),
          SizedBox(height: R.height(16)),
          Text("No notifications yet", style: AppTypography.bodyMd),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    return RefreshIndicator(
      onRefresh: controller.fetchNotifications,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (controller.todayNotifications.isNotEmpty) ...[
            _buildSectionHeader("TODAY"),
            ...controller.todayNotifications.map(
              (n) => _buildNotificationCard(n),
            ),
            SizedBox(height: R.height(24)),
          ],
          if (controller.previousNotifications.isNotEmpty) ...[
            _buildSectionHeader("PREVIOUS"),
            ...controller.previousNotifications.map(
              (n) => _buildNotificationCard(n),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: R.width(20),
        vertical: R.height(12),
      ),
      child: Text(
        title,
        style: AppTypography.overlineXs.copyWith(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final timeStr = DateFormat('h:mm a').format(notification.createdAt);

    // Choose icon background based on type
    Color bgColor = const Color(0xFFF3F4F6);
    Color iconColor = Colors.grey.shade600;

    if (notification.type == NotificationType.TRAINING_REMINDER) {
      bgColor = const Color(0xFFEBE7FF); // Light purple from design
      iconColor = const Color(0xFF7F67CB);
    }

    return InkWell(
      onTap: () => controller.markAsRead(notification.id),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.width(20),
          vertical: R.height(16),
        ),
        color: notification.isRead
            ? Colors.transparent
            : const Color(0xFFF5F3FF),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Layered Icon
            Container(
              width: R.width(48),
              height: R.width(48),
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(
                Icons.notifications,
                color: iconColor,
                size: R.width(24),
              ),
            ),
            SizedBox(width: R.width(16)),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: AppTypography.bodySm.copyWith(
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      children: [
                        TextSpan(
                          text: "${notification.message} ",
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: timeStr,
                          style: AppTypography.bodyXs.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
