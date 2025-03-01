import 'dart:async';

import 'package:apiarium/features/auth/auth_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  late final StreamSubscription _authSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    
    on<SignIn>(_onSignIn);
    on<SignUp>(_onSignUp);
    on<SignInAnonymously>(_onSignInAnonymously);
    on<SignOut>(_onSignOut);
    on<AuthStateChanged>(_onAuthStateChanged);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<ResetPassword>(_onResetPassword);

    // Listen to auth state changes from Supabase and dispatch events
    _authSubscription = _authRepository.authStateChanges.listen((authState) {
      add(AuthStateChanged(authState));
    });
  }

  Future<void> _onSignIn(SignIn event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );
      // The auth state change listener will handle emitting Authenticated state
    } catch (e) {
      if (e is supabase.AuthException) {
        emit(AuthError(message: e.message));
      } else {
        emit(AuthError(message: e.toString()));
      }
    }
  }
  
  Future<void> _onSignUp(SignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signUp(
        email: event.email,
        password: event.password,
      );
      emit(SignedUp(email: event.email));
      // The auth state change listener will handle emitting Authenticated state
    } catch (e) {
      if (e is supabase.AuthException) {
        emit(AuthError(message: e.message));
      } else {
        emit(AuthError(message: e.toString()));
      }
    }
  }
  
  Future<void> _onSignInAnonymously(SignInAnonymously event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signInAnonymously();
      // The auth state change listener will handle emitting Authenticated state
    } catch (e) {
      if (e is supabase.AuthException) {
        emit(AuthError(message: e.message));
      } else {
        emit(AuthError(message: e.toString()));
      }
    }
  }
  
  Future<void> _onSignOut(SignOut event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _authRepository.signOut();
      // The auth state change listener will handle emitting Unauthenticated state
    } catch (e) {
      if (e is supabase.AuthException) {
        emit(AuthError(message: e.message));
      } else {
        emit(AuthError(message: e.toString()));
      }
    }
  }
  
  void _onAuthStateChanged(AuthStateChanged event, Emitter<AuthState> emit) {
    if (event.authState.event == supabase.AuthChangeEvent.signedIn) {
      emit(Authenticated(user: event.authState.session?.user));
    } else if (event.authState.event ==  supabase.AuthChangeEvent.signedOut) {
      emit(Unauthenticated());
    }
  }

  void _onCheckAuthStatus(CheckAuthStatus event, Emitter<AuthState> emit) {
    final currentUser = _authRepository.currentUser;
    if (currentUser != null) {
      emit(Authenticated(user: currentUser));
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
      if (e is supabase.AuthException) {
        emit(AuthError(message: e.message));
      } else {
        emit(AuthError(message: e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }

}
