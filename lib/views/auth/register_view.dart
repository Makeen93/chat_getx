import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  bool _obsecurePassword = true;
  bool _obsecureConfirmPassword = true;
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
            key: _formKey,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  IconButton(
                      onPressed: () => Get.back,
                      icon: const Icon(
                        Icons.arrow_back,
                      )),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Fill in your details to get started',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.textSecondryColor),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _displayNameController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'Enter your name',
                  // border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your name';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  hintText: 'Enter your email',
                  // border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your email';
                  }
                  if (!GetUtils.isEmail(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _passwordController,
                obscureText: _obsecurePassword,
                // keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: 'Enter your Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obsecurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(
                      () {
                        _obsecurePassword = !_obsecurePassword;
                      },
                    ),
                  ),

                  // border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter your Password';
                  }
                  if (value!.length < 6) {
                    return 'Please enter at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obsecureConfirmPassword,
                // keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  hintText: ' Confirm Your Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obsecureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(
                      () {
                        _obsecureConfirmPassword = !_obsecureConfirmPassword;
                      },
                    ),
                  ),

                  // border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please confirm your Password';
                  }
                  if (value != _passwordController.text) {
                    return 'Password does not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _authController.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _authController.registerWithEmailAndPassword(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                    _displayNameController.text.trim());
                              }
                            },
                      child: _authController.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Create Account'),
                    ),
                  )),
              const SizedBox(
                height: 32,
              ),
              Row(
                children: [
                  const Expanded(
                      child: Divider(
                    color: AppTheme.borderColor,
                  )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(
                      child: Divider(
                    color: AppTheme.borderColor,
                  )),
                ],
              ),
              const SizedBox(
                height: 32,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?",
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(
                    width: 8,
                  ),
                  GestureDetector(
                      onTap: () {
                        // Get.back();
                        Get.toNamed(AppRoutes.login);
                      },
                      child: Text(
                        ' Sign In',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600),
                      )),
                ],
              )
            ])),
      ),
    )));
  }
}
