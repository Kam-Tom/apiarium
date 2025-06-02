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
  final String? name;
  final String country;
  final bool consentAccepted;

  SignUp({
    required this.email, 
    required this.password,
    this.name,
    required this.country,
    required this.consentAccepted,
  });
  
  @override
  List<Object?> get props => [email, password, name, country, consentAccepted];
}

class SignInAnonymously extends AuthEvent {
  final String? country;

  SignInAnonymously({this.country});
  
  @override
  List<Object?> get props => [country];
}

class SignOut extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class ResetPassword extends AuthEvent {
  final String email;

  ResetPassword({required this.email});
  
  @override
  List<Object> get props => [email];
}