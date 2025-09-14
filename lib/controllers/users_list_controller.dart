import 'package:chat_getx/controllers/auth_controller.dart';
import 'package:chat_getx/models/friend_request_model.dart';
import 'package:chat_getx/models/friendship_model.dart';
import 'package:chat_getx/routes/app_routes.dart';
import 'package:chat_getx/services/fireStore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';

enum UserRelationshipStatus {
  none,
  friendRequestSent,
  friendRequestReceived,
  friends,
  blocked,
}

class UsersListController extends GetxController {
  final FireStoreService _fireStoreService = FireStoreService();
  final AuthController _authController = AuthController();
  final Uuid _uuid = const Uuid();

  final RxList<UserModel> _users = <UserModel>[].obs;
  final RxList<UserModel> _filteredUsers = <UserModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _searchQuery = ''.obs;
  final RxString _error = ''.obs;

  final RxMap<String, UserRelationshipStatus> _userRelationships =
      <String, UserRelationshipStatus>{}.obs;
  final RxList<FriendRequestModel> _sentRequests = <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _receivedRequests =
      <FriendRequestModel>[].obs;
  final RxList<FriendshipModel> _friendships = <FriendshipModel>[].obs;
  List<UserModel> get users => _users;
  List<UserModel> get filteredUsers => _filteredUsers;
  bool get isLoading => _isLoading.value;
  String get searchQuery => _searchQuery.value;
  String get error => _error.value;
  Map<String, UserRelationshipStatus> get userRelationships =>
      _userRelationships;

  @override
  void onInit() {
    super.onInit();
    _loadUsers();
    _loadRelationships();
    debounce(
      _sentRequests,
      (_) => _filterUsers(),
      time: const Duration(milliseconds: 300),
    );
  }

  void _loadUsers() async {
    _users.bindStream(_fireStoreService.getAllUsersStream());
    ever(_users, (List<UserModel> userList) {
      final currentUserId = _authController.user?.uid;
      final otherUsers =
          userList.where((user) => user.id != currentUserId).toList();
      if (_searchQuery.isEmpty) {
        _filteredUsers.value = otherUsers;
      } else {
        _filterUsers();
      }
    });
  }

  void _loadRelationships() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _sentRequests.bindStream(
          _fireStoreService.getSentFriendRequestsStream(currentUserId));
      _receivedRequests
          .bindStream(_fireStoreService.getFriendRequestsStream(currentUserId));
      _friendships
          .bindStream(_fireStoreService.getFreindsStream(currentUserId));
      ever(_sentRequests, (_) => _updateAllRelationshipsStatus());
      ever(_receivedRequests, (_) => _updateAllRelationshipsStatus());
      ever(_friendships, (_) => _updateAllRelationshipsStatus());
      ever(_users, (_) => _updateAllRelationshipsStatus());
    }
  }

  void _updateAllRelationshipsStatus() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return;
    for (var user in _users) {
      {
        if (user.id != currentUserId) {
          final status = _calculateUserRelationshipStatus(user.id);
          _userRelationships[user.id] = status;
        }
      }
    }
  }

  UserRelationshipStatus _calculateUserRelationshipStatus(String userId) {
    final currentUserId = _authController.user?.uid;
    if (currentUserId == null) return UserRelationshipStatus.none;

    final friendship = _friendships.firstWhereOrNull(
      (request) =>
          (request.user1Id == currentUserId && request.user2Id == userId) ||
          (request.user1Id == userId && request.user2Id == currentUserId),
    );
    if (friendship != null) {
      if (friendship.isBlocked) return UserRelationshipStatus.blocked;
    } else
      return UserRelationshipStatus.friends;
    final sentRequest = _sentRequests.firstWhereOrNull(
      (request) =>
          request.status == FriendRequesStatus.pending &&
          request.receiverId == userId,
    );

    if (sentRequest != null) {
      return UserRelationshipStatus.friendRequestSent;
    }

    final receivedRequest = _receivedRequests.firstWhere(
      (request) =>
          request.senderId == userId &&
          request.status == FriendRequesStatus.pending,
    );
    return UserRelationshipStatus.friendRequestReceived;
    return UserRelationshipStatus.none;
  }

  void _filterUsers() {
    final currentUserId = _authController.user?.uid;
    final query = _searchQuery.value.toLowerCase();
    if (query.isEmpty) {
      _filteredUsers.value =
          _users.where((user) => user.id != currentUserId).toList();
    } else {
      _filteredUsers.value = _users
          .where((user) =>
              user.id != currentUserId &&
              (user.displayName.toLowerCase().contains(query) ||
                  user.email.toLowerCase().contains(query)))
          .toList();
    }
  }

  void updateSearchQuery(String query) {
    _searchQuery.value = query;
    // _filterUsers();
  }

  void clearSearch() {
    _searchQuery.value = '';
    // _filterUsers();
  }

  Future<void> sendFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        final request = FriendRequestModel(
          id: _uuid.v4(),
          senderId: currentUserId,
          receiverId: user.id,
          // status: FriendRequesStatus.pending,
          createdAt: DateTime.now(),
          // message: message,
        );
        _userRelationships[user.id] = UserRelationshipStatus.friendRequestSent;
        await _fireStoreService.sendFriendRequest(request);
      }
    } catch (e) {
      _userRelationships[user.id] = UserRelationshipStatus.none;
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to send friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> cancelFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        final sentRequest = _sentRequests.firstWhereOrNull(
          (request) =>
              request.status == FriendRequesStatus.pending &&
              request.receiverId == user.id,
        );
        if (sentRequest != null) {
          _userRelationships[user.id] = UserRelationshipStatus.none;
          await _fireStoreService.cancelFriendRequest(sentRequest.id);
          Get.snackbar('Success', 'Friend request cancelled');
        }
      }
    } catch (e) {
      _userRelationships[user.id] = UserRelationshipStatus.friendRequestSent;
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to cancel friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> acceptFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        final receivedRequest = _receivedRequests.firstWhereOrNull(
          (request) =>
              request.senderId == user.id &&
              request.status == FriendRequesStatus.pending,
        );
        if (receivedRequest != null) {
          _userRelationships[user.id] = UserRelationshipStatus.friends;
          await _fireStoreService.respondToFriendRequest(
              receivedRequest.id, FriendRequesStatus.accepted);
          Get.snackbar('Success', 'Friend request accepted');
        }
      }
    } catch (e) {
      _userRelationships[user.id] =
          UserRelationshipStatus.friendRequestReceived;
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to accept friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> declineFriendRequest(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;
      if (currentUserId != null) {
        final receivedRequest = _receivedRequests.firstWhereOrNull(
          (request) =>
              request.senderId == user.id &&
              request.status == FriendRequesStatus.pending,
        );
        if (receivedRequest != null) {
          _userRelationships[user.id] = UserRelationshipStatus.none;
          await _fireStoreService.respondToFriendRequest(
              receivedRequest.id, FriendRequesStatus.declined);
          Get.snackbar('Success', 'Friend request declined');
        }
      }
    } catch (e) {
      _userRelationships[user.id] =
          UserRelationshipStatus.friendRequestReceived;
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to decline friend request');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> startChat(UserModel user) async {
    try {
      _isLoading.value = true;
      final currentUserId = _authController.user?.uid;

      if (currentUserId != null) {
        final relationship =
            _userRelationships[user.id] ?? UserRelationshipStatus.none;

        if (relationship != UserRelationshipStatus.friends) {
          Get.snackbar('Info',
              'You can only start a chat with friends. Please send a friend request first.');
          return;
        }
        final chatId =
            await _fireStoreService.createOrGetChat(currentUserId, user.id);
        // Get.snackbar('Success', 'Chat started with ${user.displayName}');
        Get.toNamed(AppRoutes.chat,
            arguments: {'chatId': chatId, 'otherUser': user});
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to start chat');
    } finally {
      _isLoading.value = false;
    }
  }

  UserRelationshipStatus getUserRelationshipStatus(String userId) {
    return _userRelationships[userId] ?? UserRelationshipStatus.none;
  }

  String getRelationshipButtonText(UserRelationshipStatus status) {
    // final status = getUserRelationshipStatus(userId);
    switch (status) {
      case UserRelationshipStatus.none:
        return 'Add';
      case UserRelationshipStatus.friendRequestSent:
        return 'Request sent';
      case UserRelationshipStatus.friendRequestReceived:
        return 'Accept';
      case UserRelationshipStatus.friends:
        return 'Message';
      case UserRelationshipStatus.blocked:
        return 'Blocked';
      // default:
      //   return 'Add Friend';
    }
  }

  IconData getRelationshipButtonIcon(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none:
        return Icons.person_add;
      case UserRelationshipStatus.friendRequestSent:
        return Icons.access_time;
      case UserRelationshipStatus.friendRequestReceived:
        return Icons.check;
      case UserRelationshipStatus.friends:
        return Icons.chat_bubble_outline;
      case UserRelationshipStatus.blocked:
        return Icons.block;
    }
  }

  Color getRelationshipButtonColor(UserRelationshipStatus status) {
    switch (status) {
      case UserRelationshipStatus.none:
        return Colors.blue;
      case UserRelationshipStatus.friendRequestSent:
        return Colors.orange;
      case UserRelationshipStatus.friendRequestReceived:
        return Colors.green;
      case UserRelationshipStatus.friends:
        return Colors.blue;
      case UserRelationshipStatus.blocked:
        return Colors.redAccent;
    }
  }

  void handleRelationshipAction(UserModel user) {
    final status = getUserRelationshipStatus(user.id);
    switch (status) {
      case UserRelationshipStatus.none:
        sendFriendRequest(user);
        break;
      case UserRelationshipStatus.friendRequestSent:
        cancelFriendRequest(user);
        break;
      case UserRelationshipStatus.friendRequestReceived:
        acceptFriendRequest(user);
        break;
      case UserRelationshipStatus.friends:
        startChat(user);
        break;
      case UserRelationshipStatus.blocked:
        Get.snackbar('Info', 'This user is blocked.');
        break;
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

  void _clearError() {
    _error.value = '';
  }
}
