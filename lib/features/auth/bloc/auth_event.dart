part of 'auth_bloc.dart';

@immutable
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class SignUp extends AuthEvent {
  final String email;
  final String password;
  final String country;
  final String? language;
  final String? displayName;
  final bool consentAccepted;

  const SignUp({
    required this.email,
    required this.password,
    required this.country,
    this.language,
    this.displayName,
    this.consentAccepted = false,
  });

  @override
  List<Object?> get props => [email, password, country, language, displayName, consentAccepted];
}

class SignIn extends AuthEvent {
  final String email;
  final String password;

  const SignIn({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class SignInAnonymously extends AuthEvent {
  final String country;
  final String? language;

  const SignInAnonymously({
    required this.country,
    this.language,
  });

  @override
  List<Object?> get props => [country, language];
}

class ConvertAnonymousUser extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  const ConvertAnonymousUser({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

class ResetPassword extends AuthEvent {
  final String email;

  const ResetPassword({required this.email});

  @override
  List<Object?> get props => [email];
}

class SignOut extends AuthEvent {}
