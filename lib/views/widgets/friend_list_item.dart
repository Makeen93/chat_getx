import 'package:chat_getx/theme/app_theme.dart';
import 'package:flutter/material.dart';

import '../../models/user_model.dart';

class FriendListItem extends StatelessWidget {
  final UserModel friend;
  final String lastSeenText;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onBlock;

  const FriendListItem({
    super.key,
    required this.friend,
    required this.lastSeenText,
    required this.onTap,
    required this.onRemove,
    required this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.primaryColor,
                    child: friend.photoUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: Image.network(
                              friend.photoUrl,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                            ))
                        : _buildDefaultAvatar(),
                  ),
                  if (friend.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppTheme.secondryColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.displayName,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(friend.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondryColor,
                            ),
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      lastSeenText,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: friend.isOnline
                                ? AppTheme.successColor
                                : AppTheme.textSecondryColor,
                            fontWeight: friend.isOnline
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (String value) {
                  switch (value) {
                    case 'message':
                      onTap();
                      break;
                    case 'remove':
                      onRemove();
                      break;
                    case 'block':
                      onBlock();
                      break;
                  }
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem(
                      value: 'message',
                      child: ListTile(
                        leading: Icon(
                          Icons.chat_bubble_outline,
                          color: AppTheme.primaryColor,
                        ),
                        contentPadding: EdgeInsets.zero,
                        title: Text('Message'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'remove',
                      child: ListTile(
                        leading: Icon(
                          Icons.person_remove,
                          color: AppTheme.errorColor,
                        ),
                        contentPadding: EdgeInsets.zero,
                        title: Text('Remove Friend'),
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'block',
                      child: ListTile(
                        leading: Icon(
                          Icons.block,
                          color: AppTheme.errorColor,
                        ),
                        contentPadding: EdgeInsets.zero,
                        title: Text('Block'),
                      ),
                    ),
                  ];
                },
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Text(
      friend.displayName.isNotEmpty ? friend.displayName[0].toUpperCase() : '?',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
