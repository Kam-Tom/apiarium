import '../../../shared/services/api_service.dart';
import '../../../shared/services/user_service.dart';
import '../../../shared/models/user_model.dart';

class AuthRepository {
  final ApiService _apiService;
  final UserService _userService;
  
  AuthRepository(this._apiService, this._userService);
  
  /// Signs in with email and password
  Future<bool> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _userService.login(email, password);
  }
  
  /// Signs up a new user with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    String? name,
    required String country,
    required bool consentAccepted,
  }) async {
    return await _userService.register(
      email: email,
      password: password,
      name: name,
      country: country,
      consentAccepted: consentAccepted,
    );
  }

  /// Upgrade anonymous user to registered user
  Future<bool> upgradeAnonymousUser({
    required String email,
    required String password,
    String? name,
    required bool consentAccepted,
  }) async {
    return await _userService.upgradeAnonymousToRegistered(
      email: email,
      password: password,
      name: name,
      consentAccepted: consentAccepted,
    );
  }

  /// Signs out the currently authenticated user
  Future<void> signOut() async {
    await _userService.logout();
  }

  /// Reset password for email
  Future<void> resetPasswordForEmail(String email) async {
    await _apiService.post('/auth/reset-password', data: {'email': email});
  }

  /// Signs in anonymously (works offline)
  Future<bool> signInAnonymously({String? country}) async {
    return await _userService.loginAnonymously(country: country);
  }

  User? get currentUser => _userService.currentUser;
  bool get isLoggedIn => _userService.isLoggedIn;
}