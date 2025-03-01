part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final supabase.User? user;
  
  Authenticated({this.user});
  
  @override
  List<Object?> get props => [user?.id];
}

class Unauthenticated extends AuthState {}

/// State representing a user who has successfully registered but may need
/// to complete additional steps like email verification
class SignedUp extends AuthState {
  final bool requiresEmailVerification;
  final String? email;
  final String? message;
  
  SignedUp({
    this.requiresEmailVerification = false,
    this.email,
    this.message,
  });
  
  @override
  List<Object?> get props => [requiresEmailVerification, email, message];
}

/// State indicating that a password reset email has been sent
class PasswordResetSent extends AuthState {
  final String email;
  
  PasswordResetSent({required this.email});
  
  @override
  List<Object> get props => [email];
}

class AuthError extends AuthState {
  final String? message;
  
  AuthError({this.message});
  
  @override
  List<Object?> get props => [message];
}
