import 'package:chat_getx/routes/app_routes.dart';
import 'package:chat_getx/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
        actions: [
          Obx(() => TextButton(
              onPressed: controller.isEditing
                  ? controller.toggleEditing
                  : controller.toggleEditing,
              child: Text(
                controller.isEditing ? 'Cancel' : 'Edit',
                style: TextStyle(
                    color: controller.isEditing
                        ? AppTheme.errorColor
                        : AppTheme.primaryColor),
              ))),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.error.isNotEmpty) {
          return Center(child: Text(controller.error));
        }
        final user = controller.currentUser;
        if (user == null) {
          return const Center(child: Text('No user data available'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppTheme.primaryColor,
                        child: user.photoUrl.isEmpty
                            ? ClipOval(
                                child: Image.network(
                                user.photoUrl,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDefaultAvatar(user);
                                },
                              ))
                            : _buildDefaultAvatar(user),
                      ),
                      if (controller.isEditing)
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(20),
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 20),
                                onPressed: () {
                                  Get.snackbar(
                                      'Info', 'Photo Update Coming Soon');
                                },
                              ),
                            )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user.displayName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textSecondryColor),
                  ),
                  const SizedBox(height: 8),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isOnline
                            ? AppTheme.successColor.withOpacity(0.1)
                            : AppTheme.textSecondryColor
                          ..withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: user.isOnline
                                  ? AppTheme.successColor
                                  : AppTheme.textSecondryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user.isOnline ? 'Online' : 'Offline',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: user.isOnline
                                          ? AppTheme.successColor
                                          : AppTheme.textSecondryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                        ],
                      )),
                  const SizedBox(height: 8),
                  Text(controller.getJoinedData(),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppTheme.textSecondryColor)),
                ],
              ),
              const SizedBox(height: 32),
              Obx(
                () => Card(
                  child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Personel Information',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 18)),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: controller.displayNameController,
                            enabled: controller.isEditing,
                            decoration: const InputDecoration(
                              labelText: 'Display Name',
                              prefixIcon: Icon(Icons.person_outlined),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: controller.emailController,
                            enabled: false,
                            decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email_outlined),
                                helperText: 'Email cannot be changed'),
                          ),
                          if (controller.isEditing) ...[
                            SizedBox(
                              height: double.infinity,
                              child: ElevatedButton(
                                onPressed: controller.isLoading
                                    ? null
                                    : controller.updateProfile,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(50),
                                ),
                                child: controller.isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child:
                                            CircularProgressIndicator.adaptive(
                                          strokeWidth: 2,
                                          backgroundColor: Colors.white,
                                        ),
                                      )
                                    : const Text('Save Changes'),
                              ),
                            ),
                          ]
                        ],
                      )),
                ),
              ),
              const SizedBox(height: 32),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.security,
                          color: AppTheme.primaryColor),
                      title: const Text('Change Password'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Get.toNamed(AppRoutes.changePassword);
                      },
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    ListTile(
                      leading: const Icon(Icons.delete_forever,
                          color: AppTheme.errorColor),
                      title: const Text('Delete Account'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: controller.deleteAccount,
                    ),
                    const Divider(height: 1, color: Colors.grey),
                    ListTile(
                      leading: const Icon(Icons.logout,
                          color: AppTheme.primaryColor),
                      title: const Text('Sign Out'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: controller.signOut,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text('ChatApp v1.0.0',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppTheme.textSecondryColor)),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDefaultAvatar(user) {
    return Text(
      user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
      style: const TextStyle(
          fontWeight: FontWeight.w600, fontSize: 32, color: Colors.white),
    );
  }
}
