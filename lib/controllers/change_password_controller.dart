import 'package:chat_getx/controllers/auth_controller.dart';
import 'package:chat_getx/theme/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isObscureCurrent = true.obs;
  final RxBool _isObscureNew = true.obs;
  final RxBool _isObscureConfirm = true.obs;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isObscureCurrent => _isObscureCurrent.value;
  bool get isObscureNew => _isObscureNew.value;
  bool get isObscureConfirm => _isObscureConfirm.value;

  @override
  void onClose() {
    confirmPasswordController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    super.onClose();
  }

  void toggleObscureCurrent() {
    _isObscureCurrent.value = !_isObscureCurrent.value;
  }

  void toggleObscureNew() {
    _isObscureNew.value = !_isObscureNew.value;
  }

  void toggleObscureConfirm() {
    _isObscureConfirm.value = !_isObscureConfirm.value;
  }

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (newPassword != confirmPassword) {
      _error.value = 'New password and confirm password do not match';
      return;
    }
    try {
      _isLoading.value = true;
      _error.value = '';
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }
      // final credential = EmailAuthProvider.credential(
      //     email: user.email!, password: currentPassword);
      // await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      // await _authController.signOut();
      // Close the change password view on success
      Get.snackbar('Success', 'Password changed successfully',
          backgroundColor: AppTheme.successColor.withOpacity(0.1),
          colorText: AppTheme.secondryColor,
          duration: const Duration(seconds: 3));
      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();
      await _authController.signOut();
      // Get.back();
    } on FirebaseException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'The current password is incorrect.';
          break;
        case 'weak-password':
          errorMessage = 'The new password is too weak.';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Please re-authenticate and try again to change your password.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      _error.value = e.toString();
      Get.snackbar('Success', 'Password changed successfully',
          backgroundColor: AppTheme.errorColor.withOpacity(0.1),
          colorText: AppTheme.errorColor,
          duration: const Duration(seconds: 4));
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to change password',
          backgroundColor: AppTheme.errorColor.withOpacity(0.1),
          colorText: AppTheme.errorColor,
          duration: const Duration(seconds: 4));
    } finally {
      _isLoading.value = false;
    }
  }

  String? validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your current password';
    }

    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (value == currentPasswordController.text.trim()) {
      return 'New password must be different from current password';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != newPasswordController.text.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  void clearError() {
    _error.value = '';
  }
}
