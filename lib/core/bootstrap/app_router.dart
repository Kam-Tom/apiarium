import 'package:apiarium/features/sign_up/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static final AppRouter _instance = AppRouter._internal();

  factory AppRouter() {
    return _instance;
  }

  AppRouter._internal();

  static const String home = '/';
  static const String details = 'details';

  late final GoRouter router = GoRouter(
    routes: <RouteBase>[
      GoRoute(
        path: home,
        builder: (BuildContext context, GoRouterState state) {
          return const SignUp();
        },
        routes: <RouteBase>[
          GoRoute(
            path: details,
            builder: (BuildContext context, GoRouterState state) {
              return const SignUp();
            },
          ),
        ],
      ),
    ],
  );
}