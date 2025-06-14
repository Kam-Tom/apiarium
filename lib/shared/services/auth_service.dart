import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';
import 'dart:async';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late StreamSubscription<User?> _authSubscription;

  AuthService() {
    _authSubscription = _auth.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? false;

  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      Logger.e('Anonymous sign in failed', tag: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Logger.e('Sign in failed', tag: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<UserCredential?> signUpWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Logger.e('Sign up failed', tag: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<UserCredential?> linkAnonymousWithEmail(String email, String password) async {
    try {
      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous) {
        final credential = EmailAuthProvider.credential(email: email, password: password);
        return await _auth.currentUser!.linkWithCredential(credential);
      } else {
        throw Exception('No anonymous user to link');
      }
    } catch (e) {
      Logger.e('Link anonymous user failed', tag: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Logger.i('Password reset email sent to $email', tag: 'AuthService');
    } catch (e) {
      Logger.e('Password reset failed', tag: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAnonymousAccount() async {
    try {
      if (_auth.currentUser != null && _auth.currentUser!.isAnonymous) {
        await _auth.currentUser!.delete();
      }
    } catch (e) {
      Logger.e('Delete anonymous account failed', tag: 'AuthService', error: e);
      rethrow;
    }
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.updateDisplayName(displayName);
        if (photoURL != null) {
          await _auth.currentUser!.updatePhotoURL(photoURL);
        }
        Logger.i('Profile updated', tag: 'AuthService');
      }
    } catch (e) {
      Logger.e('Profile update failed', tag: 'AuthService', error: e);
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}