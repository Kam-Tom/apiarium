import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../utils/shared_prefs_helper.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class UserService extends ChangeNotifier {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  
  User? _currentUser;

  UserService(this._apiService);

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isAnonymous => _currentUser?.isAnonymous ?? false;
  bool get needsSync => _currentUser?.needsSync ?? false;

  // Getter for the user's language
  String get language => SharedPrefsHelper.getLanguage();
  
  // Setter to allow changing the language
  set language(String newLanguage) {
    SharedPrefsHelper.setLanguage(newLanguage);
  }

  // Regular login
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        await _apiService.saveTokens(data['accessToken'], data['refreshToken']);
        _currentUser = User.fromJson(data['user']); // Backend returns full user with consent/country
        await _saveUserToStorage();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }
    return false;
  }

  // Regular registration with consent and country
  Future<bool> register({
    required String email, 
    required String password,
    String? name,
    required String country,
    required bool consentAccepted,
  }) async {
    try {
      final response = await _apiService.post('/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
        'country': country,
        'consentAccepted': consentAccepted,
        'consentAcceptedAt': consentAccepted ? DateTime.now().toIso8601String() : null,
        'metadata': {
          'platform': 'mobile',
          'registrationSource': 'app',
        }
      });

      if (response.statusCode == 201) {
        final data = response.data;
        await _apiService.saveTokens(data['accessToken'], data['refreshToken']);
        _currentUser = User.fromJson(data['user']);
        await _saveUserToStorage();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
    }
    return false;
  }

  // Convert anonymous user to registered user
  Future<bool> upgradeAnonymousToRegistered({
    required String email,
    required String password,
    String? name,
    required bool consentAccepted,
  }) async {
    if (_currentUser?.isAnonymous != true) return false;

    try {
      final response = await _apiService.post('/auth/upgrade-anonymous', data: {
        'email': email,
        'password': password,
        'name': name,
        'country': _currentUser!.country, // Keep existing country
        'consentAccepted': consentAccepted,
        'consentAcceptedAt': consentAccepted ? DateTime.now().toIso8601String() : null,
        'metadata': {
          'platform': 'mobile',
          'upgradedFrom': 'anonymous',
          'originalCreatedAt': _currentUser!.createdAt.toIso8601String(),
        }
      });

      if (response.statusCode == 200) {
        final data = response.data;
        await _apiService.saveTokens(data['accessToken'], data['refreshToken']);
        _currentUser = User.fromJson(data['user']);
        await _saveUserToStorage();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Upgrade error: $e');
    }
    return false;
  }

  // Anonymous login - simplified
  Future<bool> loginAnonymously({String? country}) async {
    try {
      // Check for existing anonymous user
      if (_currentUser?.isAnonymous == true) {
        _trySyncInBackground();
        return true;
      }

      // Try online first, fallback to offline
      return await _tryOnlineAnonymousLogin(country) || 
             await _createOfflineAnonymousUser(country);
    } catch (e) {
      debugPrint('Anonymous login error: $e');
      return await _createOfflineAnonymousUser(country);
    }
  }

  Future<bool> _tryOnlineAnonymousLogin(String? country) async {
    try {
      final response = await _apiService.post('/auth/anonymous', data: {
        'country': country,
        'consentAccepted': false,
        'metadata': {
          'platform': 'mobile',
          'createdOffline': false,
        }
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        await _apiService.saveTokens(data['accessToken'], data['refreshToken']);
        
        _currentUser = User.fromJson(data['user']).copyWith(
          status: UserStatus.cached,
          anonymousPassword: data['anonymousPassword'], // Backend provides this
        );
        
        await _saveUserToStorage();
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Online anonymous login failed: $e');
    }
    return false;
  }

  Future<bool> _createOfflineAnonymousUser(String? country) async {
    try {
      _currentUser = User.createAnonymous(country: country);
      await _saveUserToStorage();
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Offline anonymous creation failed: $e');
      return false;
    }
  }

  Future<void> _trySyncInBackground() async {
    if (!needsSync) return;

    try {
      final response = await _apiService.post('/auth/anonymous', data: {
        'localId': _currentUser!.id,
        'country': _currentUser!.country,
        'consentAccepted': _currentUser!.consentAccepted,
        'metadata': {
          'platform': 'mobile',
          'createdOffline': true,
          'originalCreatedAt': _currentUser!.createdAt.toIso8601String(),
        }
      });
      
      if (response.statusCode == 200) {
        final data = response.data;
        await _apiService.saveTokens(data['accessToken'], data['refreshToken']);
        
        _currentUser = _currentUser!.copyWith(
          id: data['user']['id'],
          status: UserStatus.cached,
          anonymousPassword: data['anonymousPassword'],
        );
        
        await _saveUserToStorage();
        notifyListeners();
        debugPrint('Anonymous user synced successfully');
      }
    } catch (e) {
      debugPrint('Background sync failed: $e');
    }
  }

  // Update user consent
  Future<void> updateConsent(bool accepted) async {
    if (_currentUser == null) return;

    _currentUser = _currentUser!.copyWith(
      consentAccepted: accepted,
      consentAcceptedAt: accepted ? DateTime.now() : null,
    );

    await _saveUserToStorage();
    notifyListeners();

    // Try to sync to backend
    if (!needsSync) {
      try {
        await _apiService.post('/user/consent', data: {
          'consentAccepted': accepted,
          'consentAcceptedAt': _currentUser!.consentAcceptedAt?.toIso8601String(),
        });
      } catch (e) {
        debugPrint('Consent sync failed: $e');
      }
    }
  }

  Future<void> logout() async {
    if (_currentUser?.isAnonymous == true) {
      // For anonymous users, just clear locally
      await _clearUserFromStorage();
    } else {
      // For registered users, notify backend
      await _apiService.post('/auth/logout');
      await _apiService.clearTokens();
      await _clearUserFromStorage();
    }
    
    _currentUser = null;
    notifyListeners();
  }

  // Storage methods - simplified
  Future<void> _saveUserToStorage() async {
    if (_currentUser != null) {
      await _secureStorage.write(
        key: 'user_data', 
        value: _currentUser!.toJsonString()
      );
    }
  }

  Future<void> _loadUserFromStorage() async {
    try {
      final userData = await _secureStorage.read(key: 'user_data');
      if (userData != null && userData.isNotEmpty) {
        _currentUser = User.fromJsonString(userData);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  Future<void> _clearUserFromStorage() async {
    await _secureStorage.delete(key: 'user_data');
  }

  Future<void> initialize() async {
    await _loadUserFromStorage();
    
    // Try sync if needed
    if (needsSync) {
      _trySyncInBackground();
    }
  }
}