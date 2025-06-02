import 'dart:async';

import 'package:apiarium/features/auth/auth_repository.dart';
import 'package:apiarium/features/auth/repositories/auth_repository.dart';
import 'package:apiarium/shared/models/user_model.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    
    on<SignIn>(_onSignIn);
    on<SignUp>(_onSignUp);
    on<SignInAnonymously>(_onSignInAnonymously);
    on<SignOut>(_onSignOut);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ResetPassword>(_onResetPassword);
  }

  Future<void> _onSignIn(SignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      
      if (success) {
        emit(Authenticated(user: _authRepository.currentUser));
      } else {
        emit(AuthError(message: 'Invalid email or password'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onSignUp(SignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _authRepository.signUp(
        email: event.email,
        password: event.password,
        name: event.name,
        country: event.country,
        consentAccepted: event.consentAccepted,
      );
      
      if (success) {
        emit(Authenticated(user: _authRepository.currentUser));
      } else {
        emit(AuthError(message: 'Registration failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
  
  Future<void> _onSignInAnonymously(SignInAnonymously event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final success = await _authRepository.signInAnonymously(
        country: event.country,
      );
      
      if (success) {
        emit(Authenticated(user: _authRepository.currentUser));
      } else {
        emit(AuthError(message: 'Anonymous login failed'));
      }
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }

  void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) {
    if (_authRepository.isLoggedIn) {
      emit(Authenticated(user: _authRepository.currentUser));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onResetPassword(ResetPassword event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.resetPasswordForEmail(event.email);
      emit(PasswordResetSent(email: event.email));
    } catch (e) {
      emit(AuthError(message: e.toString()));
    }
  }
}
