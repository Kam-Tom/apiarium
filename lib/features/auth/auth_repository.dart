import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient = Supabase.instance.client;
  
  /// Signs in with email and password
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  /// Signs up a new user with email and password
  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  /// Signs out the currently authenticated user
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  /// Signs in anonymously without requiring credentials
  Future<AuthResponse> signInAnonymously() async {
    return await _supabaseClient.auth.signInAnonymously();
  }

  /// Signs in anonymously without requiring credentials
  Future<void> resetPasswordForEmail(String email) async {
     await _supabaseClient.auth.resetPasswordForEmail(email);
  }

  /// Gets the current authenticated user
  User? get currentUser => _supabaseClient.auth.currentUser;
  
  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;
}