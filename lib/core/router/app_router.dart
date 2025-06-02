import 'package:apiarium/features/auth/auth.dart';
import 'package:apiarium/features/home/home.dart';
import 'package:apiarium/features/raport/raport_page.dart';
import 'package:apiarium/features/managment/managment_page.dart';
import 'package:apiarium/features/managment/apiaries/apiaries_page.dart';
import 'package:apiarium/features/managment/hives/hives_page.dart';
import 'package:apiarium/features/managment/queens/queens_page.dart';
import 'package:apiarium/features/managment/edit_apiary/edit_apiary_page.dart';
import 'package:apiarium/features/managment/edit_hive/edit_hive_page.dart';
import 'package:apiarium/features/managment/edit_queen/edit_queen_page.dart';
import 'package:apiarium/features/vc/vc_page.dart';
import 'package:apiarium/features/vc/vc_inspection/vc_inspection_page.dart';
import 'package:apiarium/shared/layouts/main_layout.dart';
import 'package:apiarium/shared/utils/shared_prefs_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  // Route constants
  static const String home = '/';
  static const String social = '/social';
  static const String shop = '/shop';
  static const String more = '/more';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String raport = '/raport';
  static const String managment = '/managment';
  static const String voiceControl = '/vc';
  static const String voiceControlInspection = '/vc-inspection';
  static const String queens = '/queens';
  static const String editQueen = '/edit-queen';
  static const String apiaries = '/apiaries';
  static const String editApiary = '/edit-apiary';
  static const String hives = '/hives';
  static const String editHive = '/edit-hive';

  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      // Auth routes
      GoRoute(
        path: signIn,
        builder: (context, state) => const SignInPage(),
      ),
      GoRoute(
        path: signUp,
        builder: (context, state) => const SignUpPage(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainLayout(
          currentIndex: _getCurrentIndex(state.uri.path),
          child: child,
        ),
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const HomePage(),
          ),
          // Add other main tabs here if needed
        ],
      ),

      // Standalone pages
      GoRoute(
        path: voiceControl,
        builder: (context, state) {
          final vcModel = SharedPrefsHelper.getVcModel();
          return vcModel.isNotEmpty 
              ? const VcInspectionPage() 
              : const VCPage();
        },
      ),
      GoRoute(
        path: voiceControlInspection,
        builder: (context, state) => const VcInspectionPage(),
      ),
      GoRoute(
        path: raport,
        builder: (context, state) => const RaportPage(),
      ),
      GoRoute(
        path: managment,
        builder: (context, state) => const ManagmentPage(),
      ),

      // Management sub-pages
      GoRoute(
        path: apiaries,
        builder: (context, state) => const ApiariesPage(),
      ),
      GoRoute(
        path: editApiary,
        builder: (context, state) => EditApiaryPage(
          apiaryId: state.extra as String?,
        ),
      ),
      GoRoute(
        path: hives,
        builder: (context, state) => const HivesPage(),
      ),
      GoRoute(
        path: editHive,
        builder: (context, state) => _buildEditHivePage(state.extra),
      ),
      GoRoute(
        path: queens,
        builder: (context, state) => const QueensPage(),
      ),
      GoRoute(
        path: editQueen,
        builder: (context, state) => _buildEditQueenPage(state.extra),
      ),
    ],
    redirect: _handleRedirect,
  );

  // Helper method to get current nav index
  int _getCurrentIndex(String path) {
    if (path.startsWith(social)) return 1;
    if (path.startsWith(shop)) return 2;
    if (path.startsWith(more)) return 3;
    return 0; // Home
  }

  // Helper for edit hive page with parameters
  Widget _buildEditHivePage(Object? extra) {
    if (extra is String) {
      return EditHivePage(hiveId: extra);
    } else if (extra is Map<String, dynamic>) {
      return EditHivePage(
        hiveId: extra['hiveId'] as String?,
        skipSaving: extra['skipSaving'] as bool? ?? false,
        hideLocation: extra['hideLocation'] as bool? ?? false,
      );
    }
    return const EditHivePage();
  }

  // Helper for edit queen page with parameters
  Widget _buildEditQueenPage(Object? extra) {
    if (extra is String) {
      return EditQueenPage(queenId: extra);
    } else if (extra is Map<String, dynamic>) {
      return EditQueenPage(
        queenId: extra['queenId'] as String?,
        skipSaving: extra['skipSaving'] as bool? ?? false,
        hideLocation: extra['hideLocation'] as bool? ?? false,
      );
    }
    return const EditQueenPage();
  }

  // Simplified redirect logic
  String? _handleRedirect(context, state) {
    final currentPath = state.uri.path;
    final authState = authBloc.state;
    
    // Skip redirect during loading
    if (authState is AuthLoading || authState is AuthInitial) {
      return null;
    }

    final isAuthenticated = authState is Authenticated;
    final isAuthPage = currentPath == signIn || currentPath == signUp;

    // Redirect unauthenticated users to signup
    if (!isAuthenticated && !isAuthPage) {
      return signUp;
    }

    // Redirect authenticated users away from auth pages
    if (isAuthenticated && isAuthPage) {
      return home;
    }

    return null;
  }
}