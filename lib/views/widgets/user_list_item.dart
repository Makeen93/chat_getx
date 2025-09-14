import 'package:chat_getx/controllers/users_list_controller.dart';
import 'package:chat_getx/models/user_model.dart';
import 'package:chat_getx/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

class UserListItem extends StatelessWidget {
  final UserModel user;
  final VoidCallback onTap;
  final UsersListController controller;

  const UserListItem({
    super.key,
    required this.user,
    required this.onTap,
    required this.controller,
  });
  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final relationshipStatus =
            controller.getUserRelationshipStatus(user.id);
        if (relationshipStatus == UserRelationshipStatus.friends) {
          return const SizedBox.shrink();
        }
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryColor,
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ),
                ),
                Column(
                  children: [
                    _buildActionButton(relationshipStatus),
                    if(relationshipStatus == UserRelationshipStatus.friendRequestReceived)...[SizedBox(height: 4,),OutlinedButton.icon(
                      onPressed: () => controller.declineFriendRequest(user),label: Text('Decline',style: TextStyle(fontSize: 10),),
                      icon: Icon(Icons.close,size: 14,),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                        side: BorderSide(color: Colors.redAccent),
                        padding: EdgeInsets.symmetric(horizontal: 4,vertical: 8),
                        minimumSize: Size(0,24)
                      ),
                    )]
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none:
        return ElevatedButton.icon(
          onPressed: () => controller.handleRelationshipAction(user),
          label: Text(
            controller.getRelationshipButtonText(status),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: controller.getRelationshipButtonColor(status),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 32)),
        );

      case UserRelationshipStatus.friendRequestSent:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                  color: controller
                      .getRelationshipButtonColor(status)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: controller.getRelationshipButtonColor(status))),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    controller.getRelationshipButtonIcon(status),
                    color: controller.getRelationshipButtonColor(status),
                    size: 16,
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(controller.getRelationshipButtonText(status),
                      style: TextStyle(
                          color: controller.getRelationshipButtonColor(status),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.cancel_outlined,
                size: 14,
              ),
              onPressed: () => _showCancelRequestDialog(),
              label: const Text(
                'Cancel',
                style: TextStyle(fontSize: 10),
              ),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  minimumSize: const Size(0, 24)),
            )
          ],
        );

      case UserRelationshipStatus.friendRequestReceived:
        return ElevatedButton.icon(
          onPressed: () => controller.handleRelationshipAction(user),
          label: Text(
            controller.getRelationshipButtonText(status),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: controller.getRelationshipButtonColor(status),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(0, 32)),
        );
      case UserRelationshipStatus.blocked:
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
              color: AppTheme.errorColor.withOpacity(0.1),
              border: Border.all(color: AppTheme.errorColor),
              borderRadius: BorderRadius.circular(8)),
          // controller.getRelationshipButtonColor(status).withOpacity(0.1),

          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.block,
                color: AppTheme.errorColor,
                size: 16,
              ),
              SizedBox(
                width: 4,
              ),
              Text('Blocked',
                  style: TextStyle(
                      color: AppTheme.errorColor, fontWeight: FontWeight.w600)),
            ],
          ),
        );
      case UserRelationshipStatus.friends:
        return const SizedBox.shrink();
    }
  }

  void _showCancelRequestDialog() {
    Get.dialog(AlertDialog(
      title: const Text('Cancel Friend Request'),
      content: Text(
          'Are you sure you want to cancel the friend request to ${user.displayName}?'),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text('Keep Request'),
        ),
        TextButton(
          onPressed: () {
            Get.back();
            controller.cancelFriendRequest(user);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.redAccent,
          ),
          child: const Text('Cancel Request'),
        ),
      ],
    ));
  }
}
