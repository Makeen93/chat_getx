import 'package:chat_getx/controllers/auth_controller.dart';
import 'package:chat_getx/models/friend_request_model.dart';
import 'package:chat_getx/models/user_model.dart';
import 'package:chat_getx/services/fireStore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FriendRequestsController extends GetxController {
  final FireStoreService _fireStoreService = Get.find<FireStoreService>();
  final AuthController _authController = Get.find<AuthController>();
  final RxList<FriendRequestModel> _receivedRequests =
      <FriendRequestModel>[].obs;
  final RxList<FriendRequestModel> _sentRequests = <FriendRequestModel>[].obs;
  final RxMap<String, UserModel> _users = <String, UserModel>{}.obs;
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxInt _selectedTabIndex = 0.obs;

  List<FriendRequestModel> get receivedRequests => _receivedRequests.toList();
  List<FriendRequestModel> get sentRequests => _sentRequests.toList();
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  int get selectedTabIndex => _selectedTabIndex.value;
  Map<String, UserModel> get users => _users;

  @override
  void onInit() {
    super.onInit();
    loadFriendRequests();
    _loadUsers();
  }

  void loadFriendRequests() {
    final currentUserId = _authController.user?.uid;

    if (currentUserId != null) {
      _receivedRequests
          .bindStream(_fireStoreService.getFriendRequestsStream(currentUserId));
      _sentRequests.bindStream(
          _fireStoreService.getSentFriendRequestsStream(currentUserId));
    }
  }

  void _loadUsers() {
    _users.bindStream(_fireStoreService.getAllUsersStream().map((userList) {
      final userMap = <String, UserModel>{};
      for (var user in userList) {
        userMap[user.id] = user;
      }
      return userMap;
    }));
  }

  void changeTab(int index) {
    _selectedTabIndex.value = index;
  }

  UserModel? getUser(String userId) {
    return _users[userId];
  }

  Future<void> acceptRequest(FriendRequestModel request) async {
    try {
      _isLoading.value = true;
      await _fireStoreService.respondToFriendRequest(
          request.id, FriendRequesStatus.accepted);
      Get.snackbar('Success', 'Friend request accepted');
    } catch (e) {
      _error.value = 'Failed to accept friend request: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> declineRequest(FriendRequestModel request) async {
    try {
      _isLoading.value = true;
      await _fireStoreService.respondToFriendRequest(
          request.id, FriendRequesStatus.declined);
      Get.snackbar('Success', 'Friend request declined');
    } catch (e) {
      _error.value = 'Failed to decline friend request: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> unblockUser(String userId) async {
    try {
      _isLoading.value = true;
      await _fireStoreService.unBlockUser(_authController.user!.uid, userId);
      Get.snackbar('Success', 'User unblocked successfully');
    } catch (e) {
      _error.value = 'Failed to unblock user: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  String getRequestTimeText(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  String getStatusText(FriendRequesStatus status) {
    switch (status) {
      case FriendRequesStatus.pending:
        return 'Pending';
      case FriendRequesStatus.accepted:
        return 'Accepted';
      case FriendRequesStatus.declined:
        return 'Declined';
    }
  }

  Color getStatusColor(FriendRequesStatus status) {
    switch (status) {
      case FriendRequesStatus.pending:
        return Colors.orange;
      case FriendRequesStatus.accepted:
        return Colors.green;
      case FriendRequesStatus.declined:
        return Colors.redAccent;
    }
  }

  void clearError() {
    _error.value = '';
  }
}
