import 'package:chat_getx/controllers/users_list_controller.dart';
import 'package:chat_getx/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widgets/user_list_item.dart';

class FindPeopleView extends GetView<UsersListController> {
  const FindPeopleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find People'),
        leading: const SizedBox(),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: Obx(
            () {
              if (controller.filteredUsers.isEmpty) {
                return _buildEmptyState();
              }
              return ListView.separated(
                  itemBuilder: (context, index) {
                    final user = controller.filteredUsers[index];

                    return UserListItem(
                        user: user,
                        onTap: () {
                          controller.handleRelationshipAction(user);
                        },
                        controller: controller);
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 8,
                    );
                  },
                  itemCount: controller.filteredUsers.length);
            },
          ))
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(Get.context!).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor.withOpacity(0.5),
            width: 1.0,
          ),
        ),
      ),
      child: TextField(
        onChanged: (value) => controller.updateSearchQuery(value),
        decoration: InputDecoration(
          hintText: 'Search people',
          prefixIcon: const Icon(
            Icons.search,
          ),
          suffixIcon: Obx(() {
            return controller.searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clearSearch();
                    },
                  )
                : const SizedBox.shrink();
          }),
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
                ? 'No results found'
                : 'No people found',
            style: Theme.of(Get.context!).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimaryColor,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            controller.searchQuery.isNotEmpty
                ? 'Try a different search term.'
                : 'All users will show here.',
            style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textPrimaryColor,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
