import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:petapp/core/themes/app_colors.dart';
import 'package:petapp/core/themes/app_typography.dart';
import 'package:petapp/shared/helpers/responsive.dart';
import 'package:petapp/shared/widgets/empty_state/app_empty_state.dart';
import 'package:petapp/shared/widgets/scaffold/app_scaffold.dart';
import 'package:petapp/shared/widgets/app_header.dart';
import 'package:petapp/shared/widgets/dashboard_page_title.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  static const _notificationIconAsset =
      'assets/images/bottom_navigation/notification.png';

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      horizontalPadding: 0,
      body: Column(
        children: [
          const AppHeader(),
          const DashboardPageTitle(title: 'Notifications'),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.notifications.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: controller.notifications.isEmpty
                        ? const AppEmptyState(
                            iconAsset: _notificationIconAsset,
                            title: 'No Notifications Yet',
                            description:
                                'New alerts and updates will show up here as they happen.',
                          )
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
            SizedBox(height: R.height(12)),
          ],
          if (controller.previousNotifications.isNotEmpty) ...[
            _buildSectionHeader("PREVIOUS"),
            ...controller.previousNotifications.map(
              (n) => _buildNotificationCard(n),
            ),
          ],
          SizedBox(height: R.height(16)),
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
        title.toUpperCase(),
        style: AppTypography.overlineSm.copyWith(
          color: AppColors.headingText, // Text/text-strong #0A0A0A
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final timeStr = DateFormat('h:mm a').format(notification.createdAt);

    // Unread = not selected → bold/strong text
    // Read/selected → soft text (Body/sm #525252)
    final bool isSelected = notification.isRead;
    final Color textColor =
        isSelected ? AppColors.bodyText : AppColors.headingText;
    final Color rowBg =
        isSelected ? Colors.white : const Color(0xFFF4F0FC);
    final Color iconBg =
        isSelected ? const Color(0xFFF3F4F6) : const Color(0xFFEBE4FA);
    final Color iconColor =
        isSelected ? const Color(0xFF0A0A0A) : const Color(0xFF6C3BAA);

    return InkWell(
      onTap: () => controller.markAsRead(notification.id),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: R.width(20),
          vertical: R.height(16),
        ),
        color: rowBg,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: R.width(48),
              height: R.width(48),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: Image.asset(
                _notificationIconAsset,
                width: R.width(24),
                height: R.width(24),
                color: iconColor,
              ),
            ),
            SizedBox(width: R.width(16)),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTypography.bodySm.copyWith(color: textColor),
                  children: [
                    TextSpan(text: '${notification.message} '),
                    TextSpan(text: timeStr),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
