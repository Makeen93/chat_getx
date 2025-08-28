import 'package:chat_getx/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../theme/app_theme.dart';

class ForgetPasswordController extends GetxController {
  final AuthService _authService = AuthService();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _emailSent = false.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get emailSent => _emailSent.value;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendPasswordResetEmail() async {
    if (!formKey.currentState!.validate()) return;

    try {
      _isLoading.value = true;
      _error.value = '';
      // _emailSent.value = false;

      await _authService.sendPasswordResetEmail(emailController.text.trim());
      _emailSent.value = true;
      Get.snackbar('Success',
          'Password reset email sent to ${emailController.text.trim()}',
          backgroundColor: AppTheme.successColor.withOpacity(0.1),
          colorText: AppTheme.successColor,
          duration: const Duration(seconds: 4));
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', e.toString(),
          backgroundColor: AppTheme.errorColor.withOpacity(0.1),
          colorText: AppTheme.errorColor,
          duration: const Duration(seconds: 4));
    } finally {
      _isLoading.value = false;
    }
  }

  void goBacktoLogin() {
    Get.back();
  }

  void resendEmail() {
    _emailSent.value = false;
    sendPasswordResetEmail();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    // final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    // if (!emailRegex.hasMatch(value)) {
    //   return 'Enter a valid email address';
    // }
    if (!GetUtils.isEmail(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void clearError() {
    _error.value = '';
  }
}
