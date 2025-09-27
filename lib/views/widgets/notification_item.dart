import 'package:chat_getx/models/notification_model.dart';
import 'package:chat_getx/models/user_model.dart';
import 'package:chat_getx/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final UserModel? user;
  final String timeText;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationItem(
      {super.key,
      required this.notification,
      this.user,
      required this.timeText,
      required this.icon,
      required this.iconColor,
      required this.onTap,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          notification.isRead ? null : AppTheme.primaryColor.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24)),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: Text(
                        notification.title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: notification.isRead
                                ? FontWeight.normal
                                : FontWeight.w600),
                      )),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(4)),
                        )
                    ],
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    _getNotificationBody(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textSecondryColor),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    timeText,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textSecondryColor),
                  ),
                ],
              )),
              IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.textSecondryColor,
                    size: 20,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  String _getNotificationBody() {
    String body = notification.body;
    if (user != null) {
      switch (notification.type) {
        case NotificationType.friendRequest:
          body = '${user!.displayName} sent you a friend request';
          break;
        case NotificationType.friendRequestAccepted:
          body = '${user!.displayName} accepted your friend request';
          break;
        case NotificationType.friendRequestDeclined:
          body = '${user!.displayName} declined your friend request';
          break;
        case NotificationType.newMessage:
          body = '${user!.displayName} sent you a message';
          break;
        case NotificationType.friendRemoved:
          body = 'You are no longer friends with ${user!.displayName}';
          break;
      }
    }
    return body;
  }
}
