import 'package:chat_getx/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';

import '../../controllers/forget_password_controller.dart';

class ForgetPasswordView extends StatelessWidget {
  const ForgetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    return Scaffold(
      body: SafeArea(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: controller.goBacktoLogin,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Forget Password',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 56),
                    child: Text(
                      'Enter your email to receive password reset link',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondryColor,
                          ),
                    ),
                  ),
                  const SizedBox(height: 60),
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(50)),
                      child: const Icon(
                        Icons.lock_reset_rounded,
                        color: AppTheme.primaryColor,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Obx(() {
                    if (controller.emailSent) {
                      return _buildEmailSentContent(controller);
                    } else {
                      return _buildEmailForm(controller);
                    }
                  })
                ],
              )
            ],
          ),
        ),
      )),
    );
  }

  Widget _buildEmailForm(ForgetPasswordController controller) {
    return Column(
      children: [
        TextFormField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.email_outlined),
            hintText: 'Enter your email address',
            // border: OutlineInputBorder(),
          ),
          validator: controller.validateEmail,
          // onChanged: (value) {
          //   if (controller.error.isNotEmpty) {
          //     controller.clearError();
          //   }
          // },
        ),
        const SizedBox(height: 32),
        Obx(() {
          if (controller.error.isNotEmpty) {
            return Text(
              controller.error,
              style: const TextStyle(color: Colors.redAccent),
            );
          } else {
            return const SizedBox.shrink();
          }
        }),
        const SizedBox(height: 20),
        Obx(() {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: controller.isLoading
                  ? null
                  : controller.sendPasswordResetEmail,
              label:
                  Text(controller.isLoading ? 'Sending...' : 'Send Reset Link'),
              icon: controller.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator.adaptive(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send),
            ),
          );
        }),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Remember your password?',
              style: Theme.of(Get.context!).textTheme.bodyMedium,
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: controller.goBacktoLogin,
              child: Text(
                'Sign In',
                style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.primaryColor, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: controller.goBacktoLogin,
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmailSentContent(ForgetPasswordController controller) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.successColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.successColor.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.mark_email_read_rounded,
                color: AppTheme.successColor,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text('Email Sent!',
                  style: Theme.of(Get.context!)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('We`ve sent a password reset link to:',
                  style: Theme.of(Get.context!).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondryColor,
                      ),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(
                  'Check your email and follow the instructions to reset your password.',
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondryColor,
                      ),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: controller.resendEmail,
            label: const Text('Resend Email'),
            icon: const Icon(Icons.refresh),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.goBacktoLogin,
            label: const Text('Back to Sign In'),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline,
                size: 20,
                color: AppTheme.secondryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Didn`t receive the email? Check your spam folder or try again.',
                  style: Theme.of(Get.context!).textTheme.bodySmall?.copyWith(
                        color: AppTheme.secondryColor,
                      ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
