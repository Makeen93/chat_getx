import 'package:chat_getx/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            24,
          ),
          child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.security_rounded,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Text(
                    'Update your password',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Enter your current password and new password to update your account password.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondryColor,
                        ),
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Obx(() => TextFormField(
                        controller: controller.currentPasswordController,
                        obscureText: controller.isObscureCurrent,
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          hintText: 'Enter your current password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(controller.isObscureCurrent
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: controller.toggleObscureCurrent,
                          ),
                        ),
                        validator: controller.validateCurrentPassword,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Obx(() => TextFormField(
                        controller: controller.newPasswordController,
                        obscureText: controller.isObscureNew,
                        decoration: InputDecoration(
                          labelText: 'New Password',
                          hintText: 'Enter your new password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(controller.isObscureNew
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: controller.toggleObscureNew,
                          ),
                        ),
                        validator: controller.validateNewPassword,
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                  Obx(() => TextFormField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.isObscureConfirm,
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          hintText: 'Enter your confirm password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(controller.isObscureConfirm
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: controller.toggleObscureConfirm,
                          ),
                        ),
                        validator: controller.validateConfirmPassword,
                      )),
                  const SizedBox(
                    height: 40,
                  ),
                  Obx(
                    () => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: controller.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.security),
                        onPressed: controller.isLoading
                            ? null
                            : controller.changePassword,
                        label: Text(controller.isLoading
                            ? 'Updating...'
                            : 'Update Password'),
                      ),
                    ),
                  ),
                ],
              )),
        ),
      ),
    );
  }
}
