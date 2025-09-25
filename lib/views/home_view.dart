import 'package:chat_getx/controllers/auth_controller.dart';
import 'package:chat_getx/controllers/home_controller.dart';
import 'package:chat_getx/controllers/main_controller.dart';
import 'package:chat_getx/theme/app_theme.dart';
import 'package:chat_getx/views/widgets/chat_list_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(context, authController),
      body: Column(
        children: [
          _buildSearchBar(),
          Obx(
            () => controller.isSearching && controller.searchQuery.isNotEmpty
                ? _buildSearchResults()
                : _buildQuickFilters(),
          ),
          Expanded(
              child: RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: controller.refreshChats,
                  child: Obx(
                    () {
                      if (controller.allChats.isEmpty) {
                        if (controller.isSearching &&
                            controller.searchQuery.isNotEmpty) {
                          return _buildNoSearchResult();
                        } else if (controller.activeFilter != 'All') {
                          return _buildNoFilterResuts();
                        } else {
                          return _buildEmptyState();
                        }
                      }
                      return _buildChatsList();
                    },
                  )))
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, AuthController authController) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.textPrimaryColor,
      elevation: 0,
      title: Obx(
        () => Text(
          controller.isSearching ? 'Search Result' : 'Messages',
          // style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
      automaticallyImplyLeading: false,
      actions: [
        Obx(
          () => controller.isSearching
              ? IconButton(
                  onPressed: controller.clearSearch,
                  icon: const Icon(Icons.clear_rounded))
              : _buildNotificationButton(),
        ),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Obx(
      () {
        final unreadNotification = controller.getUnreadNotificationsCount();
        return Container(
          margin: const EdgeInsetsDirectional.only(end: 8),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: controller.openNotifications,
                  icon: const Icon(
                    Icons.notifications_outlined,
                  ),
                  iconSize: 22,
                  splashRadius: 20,
                ),
              ),
              if (unreadNotification > 0)
                Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints:
                          const BoxConstraints(minHeight: 16, minWidth: 16),
                      child: Text(
                        unreadNotification > 99
                            ? '99+'
                            : unreadNotification.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ))
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 15, 12),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
        child: TextField(
          onChanged: controller.onSearchChanged,
          decoration: InputDecoration(
              hintText: 'Search conversations...',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
              prefixIcon: Icon(
                Icons.source_rounded,
                color: Colors.grey[500],
                size: 20,
              ),
              suffixIcon: Obx(
                () => controller.searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: controller.clearSearch,
                        icon: Icon(
                          Icons.clear_rounded,
                          color: Colors.grey[500],
                          size: 18,
                        ))
                    : const SizedBox.shrink(),
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 16)),
        ),
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Obx(
              () => _buildFilterChip('All', () => controller.setFilter('All'),
                  controller.activeFilter == 'All'),
            ),
            const SizedBox(
              width: 8,
            ),
            Obx(
              () => _buildFilterChip(
                  'Unread (${controller.getUnreadCount()})',
                  () => controller.setFilter('Unread'),
                  controller.activeFilter == 'Unread'),
            ),
            const SizedBox(
              width: 8,
            ),
            Obx(
              () => _buildFilterChip(
                  'Recent (${controller.getRecentCount()})',
                  () => controller.setFilter('Recent'),
                  controller.activeFilter == 'Recent'),
            ),
            const SizedBox(
              width: 8,
            ),
            Obx(
              () => _buildFilterChip(
                  'Active (${controller.getActiveCount()})',
                  () => controller.setFilter('Active'),
                  controller.activeFilter == 'Active'),
            ),
            const SizedBox(
              width: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onTap, bool isSelected) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[200],
            borderRadius: BorderRadius.circular(20)),
        child: Text(
          label,
          style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textSecondryColor,
              fontSize: 13,
              fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 8, 18, 8),
      child: Row(
        children: [
          Obx(
            () => Text(
              'Found ${controller.filteredChats.length} result ${controller.filteredChats.length == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textSecondryColor),
            ),
          ),
          const Spacer(),
          TextButton(
              onPressed: controller.clearSearch,
              child: const Text(
                'Clear',
                style: TextStyle(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
              ))
        ],
      ),
    );
  }

  Widget _buildNoSearchResult() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(24),
          topEnd: Radius.circular(24),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                'No conversations found',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor),
              ),
              const SizedBox(
                height: 8,
              ),
              Obx(
                () => Text(
                  'No result for "${controller.searchQuery}"',
                  style: const TextStyle(color: AppTheme.textSecondryColor),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoFilterResuts() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(24),
          topEnd: Radius.circular(24),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getFilterIcon(controller.activeFilter),
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                'No ${controller.activeFilter.toLowerCase()} conversations',
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryColor),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                _getFilterEmptyMessage(controller.activeFilter),
                style: const TextStyle(color: AppTheme.textSecondryColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 24,
              ),
              ElevatedButton(
                  onPressed: () => controller.setFilter('All'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: const Text('Show all conversations'))
            ],
          ),
        ),
      ),
    );
  }

  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Unread':
        return Icons.mark_email_unread_outlined;
      case 'Recent':
        return Icons.schedule_outlined;
      case 'Active':
        return Icons.trending_up_outlined;
      default:
        return Icons.filter_list_outlined;
    }
  }

  String _getFilterEmptyMessage(String filter) {
    switch (filter) {
      case 'Unread':
        return 'All your conversations are up to date';
      case 'Recent':
        return 'No conversations from the last 3 days';
      case 'Active':
        return 'No conversations from the last week';
      default:
        return 'No conversations found';
    }
  }

  Widget _buildChatsList() {
    return Container(
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadiusDirectional.only(
            topEnd: Radius.circular(
              24,
            ),
            topStart: Radius.circular(
              24,
            ),
          )),
      child: Column(
        children: [
          if (!controller.isSearching || controller.searchQuery.isEmpty)
            _buildChatHeader(),
          Expanded(
              child: ListView.separated(
            padding: EdgeInsets.symmetric(
                vertical: controller.isSearching ? 16 : 8, horizontal: 16),
            itemCount: controller.allChats.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
              indent: 72,
            ),
            itemBuilder: (context, index) {
              final chat = controller.allChats[index];
              final otherUser = controller.getOtherUser(chat);
              if (otherUser == null) {
                return const SizedBox.shrink();
              }
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                child: ChatListItem(
                  chat: chat,
                  otherUser: otherUser,
                  lastMessageTime:
                      controller.formatLastMessageTime(chat.lastMessageTime),
                  onTap: () => controller.openChat(chat),
                ),
              );
            },
          ))
        ],
      ),
    );
  }

  Widget _buildChatHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Obx(
            () {
              String title = 'Recent Chats';
              switch (controller.activeFilter) {
                case 'Unread':
                  title = 'Unread Messages';
                  break;
                case 'Recent':
                  title = 'Recent Messages';
                  break;
                case 'Active':
                  title = 'Active Messages';
                  break;
              }
              return Text(
                title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimaryColor),
              );
            },
          ),
          Row(
            children: [
              if (controller.activeFilter != 'All')
                TextButton(
                    onPressed: controller.clearAllFilters,
                    child: const Text(
                      'Clear Filter',
                      style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13),
                    ))
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4))
      ]),
      child: FloatingActionButton.extended(
        onPressed: () {
          final mainController = Get.find<MainController>();
          mainController.changeTabIndex(1);
        },
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        icon: const Icon(
          Icons.chat_rounded,
          size: 20,
        ),
        label: const Text(
          'New Chat',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.sizeOf(Get.context!).height * 0.6,
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadiusDirectional.only(
              topEnd: Radius.circular(24),
              topStart: Radius.circular(24),
            )),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildEmptyStateIcon(),
                const SizedBox(
                  height: 24,
                ),
                _buildEmptyStateText(),
                const SizedBox(
                  height: 24,
                ),
                _buildEmptyStateActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyStateIcon() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppTheme.primaryColor.withOpacity(0.1),
          AppTheme.primaryColor.withOpacity(0.05),
        ]),
        borderRadius: BorderRadius.circular(70),
      ),
      child: const Icon(
        Icons.chat_bubble_outline_rounded,
        size: 64,
        color: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildEmptyStateText() {
    return const Column(
      children: [
        Text(
          'No conversations yet',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimaryColor),
        ),
        SizedBox(
          height: 8,
        ),
        Text(
          'Connect with friends and start meaningful conversations',
          style: TextStyle(
              fontSize: 15, color: AppTheme.textSecondryColor, height: 1.4),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyStateActions() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final mainController = Get.find<MainController>();
              mainController.changeTabIndex(2);
            },
            label: const Text(
              'Find People',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.person_search_rounded),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              final mainController = Get.find<MainController>();
              mainController.changeTabIndex(1);
            },
            label: const Text(
              'View Friends',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppTheme.primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.person_search_rounded),
          ),
        )
      ],
    );
  }
}
