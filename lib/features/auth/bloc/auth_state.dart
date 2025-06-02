part of 'auth_bloc.dart';

@immutable
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final User? user;
  
  Authenticated({this.user});
  
  @override
  List<Object?> get props => [user?.id];
}

class Unauthenticated extends AuthState {}

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
