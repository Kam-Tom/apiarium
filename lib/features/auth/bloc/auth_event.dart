part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SignIn extends AuthEvent {
  final String email;
  final String password;

  SignIn({required this.email, required this.password});
  
  @override
  List<Object> get props => [email, password];
}

class SignUp extends AuthEvent {
  final String email;
  final String password;

  SignUp({required this.email, required this.password});
  
  @override
  List<Object> get props => [email, password];
}

class SignInAnonymously extends AuthEvent {}

class SignOut extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class ResetPassword extends AuthEvent {
  final String email;

  ResetPassword({required this.email});
  
  @override
  List<Object> get props => [email];
}

class AuthStateChanged extends AuthEvent {
  final supabase.AuthState authState;

  AuthStateChanged(this.authState);
  
  @override
  List<Object> get props => [authState];
}