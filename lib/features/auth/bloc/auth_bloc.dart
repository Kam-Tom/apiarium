import 'dart:async';

import 'package:apiarium/shared/shared.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;
  final UserRepository _userRepository;
  late StreamSubscription<firebase_auth.User?> _authSubscription;

  AuthBloc({
    required AuthService authService,
    required UserRepository userRepository,
  })  : _authService = authService,
        _userRepository = userRepository,
        super(AuthInitial()) {
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser != null) {
        add(AuthCheckRequested());
      } else {
        emit(Unauthenticated());
      }
    });

    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignUp>(_onSignUp);
    on<SignIn>(_onSignIn);
    on<SignInAnonymously>(_onSignInAnonymously);
    on<ConvertAnonymousUser>(_onConvertAnonymousUser);
    on<ResetPassword>(_onResetPassword);
    on<SignOut>(_onSignOut);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final firebaseUser = _authService.currentUser;
      if (firebaseUser != null) {
        final user = await _userRepository.loginUser(firebaseUser.uid);
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(
          message: 'Failed to check authentication status',
          exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onSignUp(
    SignUp event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final credential =
          await _authService.signUpWithEmail(event.email, event.password);
      if (credential?.user != null) {
        final user = await _userRepository.registerUser(
          credential!.user!,
          event.country,
          displayName: event.displayName,
          language: event.language,
        );
        emit(Authenticated(user: user));
      } else {
        emit(const AuthError(message: 'Failed to create account'));
      }
    } catch (e) {
      emit(AuthError(
          message: _getErrorMessage(e),
          exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onSignIn(
    SignIn event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final credential =
          await _authService.signInWithEmail(event.email, event.password);
      if (credential?.user != null) {
        final user = await _userRepository.loginUser(credential!.user!.uid);
        if (user != null) {
          emit(Authenticated(user: user));
        } else {
          emit(const AuthError(message: 'User profile not found'));
        }
      } else {
        emit(const AuthError(message: 'Failed to sign in'));
      }
    } catch (e) {
      emit(AuthError(
          message: _getErrorMessage(e),
          exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onSignInAnonymously(
    SignInAnonymously event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final credential = await _authService.signInAnonymously();
      if (credential?.user != null) {
        final user = await _userRepository.createAnonymousUser(
          credential!.user!,
          event.country,
          language: event.language,
        );
        emit(Authenticated(user: user));
      } else {
        emit(const AuthError(message: 'Failed to create anonymous account'));
      }
    } catch (e) {
      emit(AuthError(
          message: _getErrorMessage(e),
          exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onConvertAnonymousUser(
    ConvertAnonymousUser event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final credential =
          await _authService.linkAnonymousWithEmail(event.email, event.password);
      if (credential?.user != null) {
        final currentUser = _userRepository.currentUser;
        if (currentUser != null) {
          final updatedUser = currentUser.copyWith(
            isAnonymous: false,
            displayName: event.displayName ?? currentUser.displayName,
            updatedAt: DateTime.now(),
          );
          await _userRepository.updateUser(updatedUser);
          emit(Authenticated(user: updatedUser));
        } else {
          emit(const AuthError(message: 'Failed to update user profile'));
        }
      } else {
        emit(const AuthError(message: 'Failed to convert anonymous account'));
      }
    } catch (e) {
      emit(AuthError(
          message: _getErrorMessage(e),
          exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onResetPassword(
    ResetPassword event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await firebase_auth.FirebaseAuth.instance
          .sendPasswordResetEmail(email: event.email);
      emit(PasswordResetSent(email: event.email));
    } catch (e) {
      emit(AuthError(
          message: _getErrorMessage(e),
          exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  Future<void> _onSignOut(
    SignOut event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authService.signOut();
      await _userRepository.clearUserData();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(
          message: 'Failed to sign out',
          exception: e is Exception ? e : Exception(e.toString())));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'weak-password':
          return 'Password is too weak.';
        case 'invalid-email':
          return 'Email address is invalid.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        default:
          return error.message ?? 'An authentication error occurred.';
      }
    }
    return error.toString();
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}

