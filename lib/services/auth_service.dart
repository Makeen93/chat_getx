import 'package:chat_getx/models/user_model.dart';
import 'package:chat_getx/services/fireStore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FireStoreService _fireStoreService = FireStoreService();
  User? get currentUser => _auth.currentUser;
  String? get currentUserId => _auth.currentUser?.uid;
  // bool get isAuthenticated => currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await _fireStoreService.updateUserOnlineStatus(user.uid, true);
        return await _fireStoreService.getUser(user.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Failed To Sign In: ${e.toString()}');
    }
  }

  Future<UserModel?> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      if (user != null) {
        await user.updateDisplayName(displayName);
        final userModel = UserModel(
          id: user.uid,
          email: email,
          displayName: displayName,
          photoUrl: '',
          isOnline: true,
          lastSeen: DateTime.now(),
          createdAt: DateTime.now(),
        );
        await _fireStoreService.createUser(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Failed To Register: ${e.toString()}');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Failed To Send Password Reset Email: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      if (currentUserId != null) {
        await _fireStoreService.updateUserOnlineStatus(currentUserId!, false);
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed To Sign Out: ${e.toString()}');
    }
  }

  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _fireStoreService.deleteUser(user.uid);
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed To Delete Account: ${e.toString()}');
    }
  }
}
