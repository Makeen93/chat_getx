import 'package:chat_getx/models/user_model.dart';
import 'package:chat_getx/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

import '../services/auth_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  final Rx<User?> _user = Rx<User?>(null);
  final Rx<UserModel?> _userModel = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isintialized = false.obs;
  User? get user => _user.value;
  UserModel? get userModel => _userModel.value;
  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  bool get isAuthenticated => _user.value != null;
  bool get isIntialized => _isintialized.value;
  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_authService.authStateChanges);
    // _user.value = _authService.currentUser;
    ever(_user, _handleAuthStateChange);
  }

  void _handleAuthStateChange(User? user) async {
    if (user != null) {
      if (Get.currentRoute != AppRoutes.login)
        Get.offAllNamed(AppRoutes.login);
      else {
        if (Get.currentRoute != AppRoutes.main) Get.offAllNamed(AppRoutes.main);
      }
      if (!_isintialized.value) _isintialized.value = true;
    }
  }

  void checkInitialAuthState() {
    final currentUser =
        // _authService.currentUser;
        FirebaseAuth.instance.currentUser;
    print('____________________________________$currentUser');
    if (currentUser != null) {
      _user.value = currentUser;
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
    _isintialized.value = true;
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      UserModel? userModel =
          await _authService.signInWithEmailAndPassword(email, password);
      if (userModel != null) {
        _userModel.value = userModel;
        _user.value = _authService.currentUser;
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to login');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      _isLoading.value = true;
      _error.value = '';

      UserModel? userModel = await _authService.registerWithEmailAndPassword(
          email, password, displayName);
      if (userModel != null) {
        _userModel.value = userModel;
        _user.value = _authService.currentUser;
        Get.offAllNamed(AppRoutes.main);
      }
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to register');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      await _authService.signOut();
      // _userModel.value = null;
      // _user.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to logout');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      await _authService.deleteAccount();
      _userModel.value = null;
      // _user.value = null;
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _error.value = e.toString();
      Get.snackbar('Error', 'Failed to delete account');
    } finally {
      _isLoading.value = false;
    }
  }
}
