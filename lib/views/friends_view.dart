import 'package:chat_getx/theme/app_theme.dart';
import 'package:chat_getx/views/widgets/friend_list_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/friends_controller.dart';

class FriendsView extends GetView<FriendsController> {
  const FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        leading: const SizedBox(),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: controller.openFriendRequests,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                    bottom: BorderSide(
                        color: AppTheme.borderColor.withOpacity(0.5),
                        width: 1))),
            child: TextField(
              onChanged: controller.updateSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Obx(() => controller.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: controller.clearSearch,
                      )
                    : const SizedBox.shrink()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: AppTheme.borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
                filled: true,
                fillColor: AppTheme.cardColor,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshFriends,
              child: Obx(
                () {
                  if (controller.isLoading && controller.friends.isNotEmpty) {
                    return const Center(
                      child: CircularProgressIndicator.adaptive(),
                    );
                  }
                  if (controller.filteredFriends.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: controller.filteredFriends.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 8);
                    },
                    itemBuilder: (context, index) {
                      final friend = controller.filteredFriends[index];
                      return FriendListItem(
                        friend: friend,
                        lastSeenText: controller.getLastSeenText(friend),
                        onTap: () => controller.startChat(friend),
                        onRemove: () => controller.removeFriend(friend),
                        onBlock: () => controller.blockFriend(friend),
                      );
                    },
                  );
                },
              ),
            ),
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
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(Icons.people_outline,
                size: 50, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            controller.searchQuery.isNotEmpty
                ? 'No friends found'
                : 'No friends yet',
            style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.isNotEmpty
                ? 'Try a different search term.'
                : 'Add friends to start chating with them.',
            style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondryColor,
                ),
            textAlign: TextAlign.center,
          ),
          if (controller.searchQuery.isEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: controller.openFriendRequests,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('View Friend Requests'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(8.0),
                // ),
                // padding: const EdgeInsets.symmetric(
                //     horizontal: 24.0, vertical: 12.0),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
