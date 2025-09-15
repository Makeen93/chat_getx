import 'dart:async';

import 'package:chat_getx/controllers/auth_controller.dart';
import 'package:chat_getx/models/friendship_model.dart';
import 'package:chat_getx/models/user_model.dart';
import 'package:chat_getx/routes/app_routes.dart';
import 'package:chat_getx/services/auth_service.dart';
import 'package:chat_getx/services/fireStore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class FriendsController extends GetxController {
  final FireStoreService _fireStoreService = Get.find<FireStoreService>();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<FriendshipModel> _friendships = <FriendshipModel>[].obs;
  final RxList<UserModel> _friends = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxString _searchQuery = ''.obs;
  final RxList<UserModel> _filteredFriends = <UserModel>[].obs;

  StreamSubscription? _friendshipSubscriptions;
  List<FriendshipModel> get friendships => _friendships;
  List<UserModel> get filteredFriends => _filteredFriends;
  List<UserModel> get friends => _friends;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  String get searchQuery => _searchQuery.value;
  // User? get currentUser => _authService.currentUser;

  @override
  void onInit() {
    super.onInit();
    _loadFriends();
    debounce(_searchQuery, (_) => _filteredFriends(),
        time: const Duration(milliseconds: 300));
  }

  @override
  void onClose() {
    _friendshipSubscriptions?.cancel();
    super.onClose();
  }

  void _loadFriends() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _friendshipSubscriptions?.cancel();
      _friendshipSubscriptions =
          _fireStoreService.getFreindsStream(currentUserId).listen(
        (friendshipList) {
          _friendships.value = friendshipList;
          _loadFriendDetails(currentUserId, friendshipList);
        },
      );
    }
  }

  Future<void> _loadFriendDetails(
      String currentUserId, List<FriendshipModel> friendshipList) async {
    try {
      _isLoading.value = true;
      List<UserModel> friendUsers = [];
      _error.value = '';

      final futures = friendshipList.map((friendship) async {
        String friendId = friendship.getOtherUserId(currentUserId);
        return await _fireStoreService.getUser(friendId);
      }).toList();
      final result = await Future.wait(futures);
      for (var friend in friends) {
        friendUsers.add(friend);
      }
      _friends.value = friendUsers;
      _filtereFriends();
    } catch (e) {
      _error.value = 'Failed to load friends: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  void _filtereFriends() {
    final query = _searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      _filteredFriends.value = _friends;
    } else {
      _filteredFriends.value = _friends.where((friend) {
        return friend.displayName.toLowerCase().contains(query) ||
            friend.email.toLowerCase().contains(query);
      }).toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
  }

  void clearSearch() {
    _searchQuery.value = '';
  }

  Future<void> refreshFriends() async {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _loadFriends();
    }
  }

  Future<void> removeFriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(AlertDialog(
        title: const Text('Remove Friend'),
        content: Text(
            'Are you sure you want to remove ${friend.displayName} from your friends?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            child: const Text('Remove'),
          ),
        ],
      ));
      if (result == true) {
        final currentUserId = _authController.user?.uid;
        if (currentUserId != null) {
          await _fireStoreService.removeFriendShip(currentUserId, friend.id);
          Get.snackbar(
            'Success',
            '${friend.displayName} has been removed from your friends.',
            backgroundColor: Colors.green.withOpacity(0.1),
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove friend',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.redAccent,
          duration: const Duration(seconds: 4));
    } finally {
      _isLoading.value = false;
      // refreshFriends();
    }
  }

  Future<void> blockFriend(UserModel friend) async {
    try {
      final result = await Get.dialog<bool>(AlertDialog(
        title: const Text('Block User'),
        content: Text(
            'Are you sure you want to block ${friend.displayName}? You will no longer be able to see each other\'s profiles or send messages.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
            ),
            child: const Text('Block'),
          ),
        ],
      ));
      if (result == true) {
        final currentUserId = _authController.user?.uid;
        if (currentUserId != null) {
          await _fireStoreService.blockUser(currentUserId, friend.id);
          Get.snackbar(
            'Success',
            '${friend.displayName} has been blocked.',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            duration: const Duration(seconds: 4),
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to block user',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.redAccent,
          duration: const Duration(seconds: 4));
    } finally {
      _isLoading.value = false;
      // refreshFriends();
    }
  }

  Future<void> startChat(UserModel friend) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        Get.toNamed(AppRoutes.chat, arguments: {
          'chatId': null,
          'otherUser': friend,
          'isNewChat': true
        });
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to start chat',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.redAccent,
          duration: const Duration(seconds: 4));
    } finally {
      _isLoading.value = false;
    }
  }

  String getLastSeenText(UserModel user) {
    if (user.isOnline) {
      return 'Online';
    } else {
      final now = DateTime.now();
      final difference = now.difference(user.lastSeen);

      if (difference.inMinutes < 1) {
        return 'just now';
      } else if (difference.inMinutes < 60) {
        return 'Last seen ${difference.inMinutes} m ago';
      } else if (difference.inDays < 1) {
        return 'Last seen ${difference.inDays} h ago';
      } else if (difference.inDays < 7) {
        return 'Last seen ${difference.inDays} d ago';
      } else {
        return 'Last seen on ${user.lastSeen.day}/${user.lastSeen.month}/${user.lastSeen.year}';
      }
    }
  }

  void openFriendRequests() {
    Get.toNamed(AppRoutes.frindRequests);
  }

  void clearError() {
    _error.value = '';
  }
}
