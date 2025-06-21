import 'package:apiarium/features/auth/auth.dart';
import 'package:apiarium/features/home/home.dart';
import 'package:apiarium/features/managment/managment_page.dart';
import 'package:apiarium/features/managment/apiaries/apiaries_page.dart';
import 'package:apiarium/features/managment/hives/hives_page.dart';
import 'package:apiarium/features/managment/queens/queens_page.dart';
import 'package:apiarium/shared/layouts/main_layout.dart';
import 'package:apiarium/shared/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String home = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String editApiary = '/edit-apiary';
  static const String editQueen = '/edit-queen';
  static const String editHive = '/edit-hive';
  static const String apiaries = '/apiaries';
  static const String hives = '/hives';
  static const String queens = '/queens';
  static const String management = '/management';

  final AuthService authService;

  AppRouter({required this.authService});

  late final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: management,
        builder: (context, state) => const ManagmentPage(),
      ),
      GoRoute(
        path: apiaries,
        builder: (context, state) => const ApiariesPage(),
      ),
      GoRoute(
        path: hives,
        builder: (context, state) => const HivesPage(),
      ),
      GoRoute(
        path: queens,
        builder: (context, state) => const QueensPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainLayout(
          currentIndex: 0,
          child: child,
        ),
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const HomePage(),
          ),
        ],
      ),
    ],
    redirect: _handleRedirect,
    refreshListenable: authService,
  );

  String? _handleRedirect(context, state) {
    final currentPath = state.uri.path;
    final isAuthenticated = authService.currentUser != null;
    final isAuthPage = currentPath == signIn || currentPath == signUp;

    if (!isAuthenticated && !isAuthPage) {
      return signUp;
    }

    if (isAuthenticated && isAuthPage) {
      return home;
    }

    return null;
  }
}