import 'package:apiarium/shared/domain/models/base_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../domain/models/user.dart';
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
    {String? displayName, String? photoURL, String? language}
  ) async {
    try {
      final now = DateTime.now();
      
      final user = User(
        id: firebaseUser.uid,
        createdAt: now,
        updatedAt: now,
        termsAccepted: true,
        termsAcceptedAt: now,
        country: country,
        language: language,
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

  Future<User> createAnonymousUser(
    firebase_auth.User firebaseUser,
    String country,
    {String? language}
  ) async {
    try {
      final now = DateTime.now();
      
      final user = User(
        id: firebaseUser.uid,
        createdAt: now,
        updatedAt: now,
        termsAccepted: true,
        termsAcceptedAt: now,
        country: country,
        language: language,
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

  Future<User> updateUser(User user) async {
    await _saveUser(user);
    Logger.i('User profile updated: ${user.id}', tag: _tag);
    return user;
  }

  Future<void> _saveUser(User user) async {
    try {
      final userToSave = user.copyWith(
        syncStatus: SyncStatus.synced,
        lastSyncedAt: DateTime.now(),
        serverVersion: user.serverVersion + 1,
      );

      await _firestore
          .collection('users')
          .doc(userToSave.id)
          .set(userToSave.toJson(), SetOptions(merge: true));

      await _cacheUser(userToSave);
      _currentUser = userToSave;
      
      Logger.i('User saved: ${userToSave.id}', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save user', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> syncUserProfile() async {
    if (_currentUser == null) return;

    try {
      final doc = await _firestore.collection('users').doc(_currentUser!.id).get();
      if (doc.exists && doc.data() != null) {
        final serverUser = User.fromJson(doc.data()!, _currentUser!.id);
        
        // Only update if server version is newer
        if (serverUser.updatedAt.isAfter(_currentUser!.updatedAt) ||
            (serverUser.updatedAt.isAtSameMomentAs(_currentUser!.updatedAt) &&
             serverUser.serverVersion > _currentUser!.serverVersion)) {
          
          final syncedUser = serverUser.copyWith(
            syncStatus: SyncStatus.synced,
            lastSyncedAt: DateTime.now(),
          );
          
          await _cacheUser(syncedUser);
          _currentUser = syncedUser;
          Logger.i('User profile synced from server: ${_currentUser!.id}', tag: _tag);
        }
      }
    } catch (e) {
      Logger.e('Failed to sync user profile', tag: _tag, error: e);
    }
  }

  Future<User> updateUserCountry(String country) async {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(
        country: country,
        // Currency will be automatically updated based on country in copyWith
        syncStatus: SyncStatus.pending,
      );
      await _saveUser(updatedUser);
      return updatedUser;
    }
    throw Exception('No current user to update');
  }

  Future<User> updateUserCurrency(String currency) async {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(
        currency: currency,
        syncStatus: SyncStatus.pending,
      );
      await _saveUser(updatedUser);
      return updatedUser;
    }
    throw Exception('No current user to update');
  }

  Future<User> updateUserLanguage(String language) async {
    if (_currentUser != null) {
      final updatedUser = _currentUser!.copyWith(
        language: language,
        syncStatus: SyncStatus.pending,
      );
      await _saveUser(updatedUser);
      return updatedUser;
    }
    throw Exception('No current user to update');
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
  Future<DateTime?> getLastSyncTime() async {
    try {
      final syncTimeString = await _storage.read(key: _lastSyncKey);
      if (syncTimeString != null) {
        return DateTime.parse(syncTimeString);
      }
      return null;
    } catch (e) {
      Logger.e('Failed to get last sync time', tag: _tag, error: e);
      return null;
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
  bool get isPremium => _currentUser?.isPremium ?? false;
}