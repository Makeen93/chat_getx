import 'package:chat_getx/controllers/notification_controller.dart';
import 'package:chat_getx/theme/app_theme.dart';
import 'package:chat_getx/views/widgets/notification_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaions'),
        leading: IconButton(
            onPressed: () => Get.back, icon: const Icon(Icons.arrow_back)),
        actions: [
          Obx(
            () {
              final unreadCount = controller.getUnreadCount();
              return unreadCount > 0
                  ? TextButton(
                      onPressed: controller.markAllAsRead,
                      child: const Text('Mark all read'))
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Obx(
        () {
          if (controller.notifications.isEmpty) {
            return _buildEmptyState();
          }
          return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                final user = notification.data['senderId'] != null
                    ? controller.getUser(notification.data['senderId'])
                    : notification.data['userId'] != null
                        ? controller.getUser(notification.data['userId'])
                        : null;
                return NotificationItem(
                  notification: notification,
                  user: user,
                  timeText: controller
                      .getNotificationTimeText(notification.createdAt),
                  icon: controller.getNotificationIcon(notification.type),
                  iconColor:
                      controller.getNotificationIconColor(notification.type),
                  onTap: () => controller.handleNotificationType(notification),
                  onDelete: () => controller.deleteNotification(notification),
                );
              },
              separatorBuilder: (context, index) => const SizedBox(
                    height: 8,
                  ),
              itemCount: controller.notifications.length);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.notifications_outlined,
                size: 50, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            'No notifications',
            style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'When you reciever freind requests, messages, or other updates, thry will appear here',
            style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondryColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
