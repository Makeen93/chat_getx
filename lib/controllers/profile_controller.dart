import 'package:chat_getx/controllers/auth_controller.dart';
import 'package:chat_getx/services/fireStore_service.dart';
import 'package:chat_getx/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';

class ProfileController extends GetxController {
  final FireStoreService _fireStoreService = FireStoreService();
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxBool _isLoading = false.obs;
  final RxBool _isEditing = false.obs;
  final RxString _error = ''.obs;
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);

  bool get isEditing => _isEditing.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  UserModel? get currentUser => _currentUser.value;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  @override
  void onClose() {
    // displayNameController.dispose();
    // emailController.dispose();
    super.onClose();
  }

  void _loadUserData() {
    final currentUserId = _authController.user?.uid;
    if (currentUserId != null) {
      _currentUser.bindStream(_fireStoreService.getUserStream(currentUserId));
      ever(_currentUser, (UserModel? user) {
        if (user != null) {
          displayNameController.text = user.displayName;
          emailController.text = user.email;
        }
      });
    }
  }

  void toggleEditing() {
    _isEditing.value = !_isEditing.value;
    if (!_isEditing.value) {
      // If exiting edit mode, reset the fields to current user data
      if (_currentUser.value != null) {
        displayNameController.text = _currentUser.value!.displayName;
        emailController.text = _currentUser.value!.email;
      }
      _error.value = '';
    }
  }

  Future<void> updateProfile() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      final user = _currentUser.value;
      if (user == null) {
        // _error.value = 'No user logged in';
        return;
      }
      final updatedUser = user.copyWith(
        displayName: displayNameController.text.trim(),
        // email: emailController.text.trim(),
      );
      await _fireStoreService.updateUser(updatedUser);
      _isEditing.value = false;
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to update profile');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      await _authController.signOut();
    } catch (e) {
      Get.snackbar('Error', 'Failed to sign out');
    }
  }

  Future<void> deleteAccount() async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
      if (result == true) {
        _isLoading.value = true;
        await _authController.deleteAccount();
      } // User cancelled the deletion
      // Get.snackbar('Success', 'Account deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete account');
    }
  }

  String getJoinedData() {
    final user = _currentUser.value;
    if (user == null) {
      return 'N/A';
    }
    final date = user.createdAt;
    final months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return 'Joined ${months[date.month - 1]} ${date.year}';
  }

  void clearError() {
    _error.value = '';
  }
}
