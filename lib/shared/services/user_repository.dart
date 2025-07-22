import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../models/user.dart';
import '../utils/logger.dart';

class UserRepository {  
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _tag = 'UserService';
  static const String _userCacheKey = 'cached_user';
  static const String _lastSyncKey = 'last_sync_time';

  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> initialize() async {
    try {
      final userJson = await _storage.read(key: _userCacheKey);
      if (userJson != null) {
        _currentUser = User.fromJsonString(userJson);
        Logger.i('Cached user loaded: ${_currentUser!.id}', tag: _tag);
      }
    } catch (e) {
      Logger.e('Failed to load cached user', tag: _tag, error: e);
    }
  }

  Future<User> registerUser(
    firebase_auth.User firebaseUser,
    String country,
    {String? displayName, String? photoURL}
  ) async {
    try {
      final now = DateTime.now();
      
      final user = User(
        id: firebaseUser.uid,
        termsAccepted: true,
        termsAcceptedAt: now,
        country: country,
        updatedAt: now,
        isAnonymous: false,
        displayName: displayName,
        photoURL: photoURL ?? firebaseUser.photoURL,
      );

      await _saveUser(user);
      Logger.i('User registered: ${user.id}', tag: _tag);
      return user;
    } catch (e) {
      Logger.e('Failed to register user', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<User?> loginUser(String uid) async {
    try {
      if (currentUser?.id == uid) {
        Logger.i('User loaded from memory: $uid', tag: _tag);
        return currentUser;
      }

      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final user = User.fromJson(doc.data()!, uid);
        await _cacheUser(user);
        _currentUser = user;
        Logger.i('User loaded from Firestore: $uid', tag: _tag);
        return user;
      }

      Logger.w('User not found: $uid', tag: _tag);
      return null;
    } catch (e) {
      Logger.e('Failed to login user: $uid', tag: _tag, error: e);
      return null;
    }
  }

  Future<User> createAnonymousUser(
    firebase_auth.User firebaseUser,
    String country,
  ) async {
    try {
      final now = DateTime.now();
      
      final user = User(
        id: firebaseUser.uid,
        termsAccepted: true,
        termsAcceptedAt: now,
        country: country,
        updatedAt: now,
        isAnonymous: true,
        displayName: null,
        photoURL: null,
      );

      await _saveUser(user);
      Logger.i('Anonymous user created: ${user.id}', tag: _tag);
      return user;
    } catch (e) {
      Logger.e('Failed to create anonymous user', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<User> updateUser(User user) async {
    await _saveUser(user);
    Logger.i('User profile updated: ${user.id}', tag: _tag);
    return user;
  }

  Future<void> _saveUser(User user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toJson(), SetOptions(merge: true));

      await _cacheUser(user);
      _currentUser = user;
      
      Logger.i('User saved: ${user.id}', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save user', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> _cacheUser(User user) async {
    await _storage.write(key: _userCacheKey, value: user.toJsonString());
  }
  Future<void> clearUserData() async {
    try {
      await _storage.delete(key: _userCacheKey);
      await _storage.delete(key: _lastSyncKey);
      _currentUser = null;
      Logger.i('User data cleared', tag: _tag);
    } catch (e) {
      Logger.e('Failed to clear user data', tag: _tag, error: e);
    }
  }

  // Sync time management
  Future<DateTime> getLastSyncTime() async {
    try {
      final syncTimeString = await _storage.read(key: _lastSyncKey);
      if (syncTimeString != null) {
        return DateTime.parse(syncTimeString);
      }
      // If no sync time, return very old date to get all data
      return DateTime(1900);
    } catch (e) {
      Logger.e('Failed to get last sync time', tag: _tag, error: e);
      return DateTime(1900);
    }
  }

  Future<void> setLastSyncTime() async {
    try {
      final now = DateTime.now();
      await _storage.write(key: _lastSyncKey, value: now.toIso8601String());
      Logger.i('Updated last sync time: $now', tag: _tag);
    } catch (e) {
      Logger.e('Failed to update last sync time', tag: _tag, error: e);
    }
  }

  bool get hasUser => _currentUser != null;
  bool get isPremium => true; // TODO: Implement RevenueCat check
}