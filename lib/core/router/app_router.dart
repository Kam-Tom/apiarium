
import 'package:apiarium/features/auth/auth.dart';
import 'package:apiarium/features/home/home.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/management/management.dart';

class AppRouter {
  static const String home = '/';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';  
  static const String editApiary = '/edit-apiary';  
  static const String editQueen = '/edit-queen'; 
  static const String editQueenBreed = '/edit-queen-breed';
  static const String editHiveType = '/edit-hive-type';
  static const String queenBreedDetail = '/queen-breed-detail';
  static const String queenDetail = '/queen-detail';
  static const String hiveTypeDetail = '/hive-type-detail';
  static const String editHive = '/edit-hive';
  static const String apiaries = '/apiaries';
  static const String hives = '/hives';  static const String queens = '/queens';
  static const String queenBreeds = '/queen-breeds';
  static const String hiveTypes = '/hive-types';
  static const String management = '/management';
  static const String apiaryDetail = '/apiary-detail';
  static const String hiveDetail = '/hive-detail';

  final AuthService authService;

  AppRouter({required this.authService});

  late final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(
        path: signIn,
        builder: (context, state) => const SignInPage(),
      ),      GoRoute(
        path: signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: management,
        builder: (context, state) => const DashboardPage(),
      ),      GoRoute(
        path: apiaries,
        builder: (context, state) => const ApiariesPage(),
      ),
      GoRoute(
        path: hives,
        builder: (context, state) => const HivesPage(),
      ),      GoRoute(
        path: queens,
        builder: (context, state) => const QueensPage(),
      ),      GoRoute(
        path: queenBreeds,
        builder: (context, state) => const QueenBreedsPage(),
      ),
      GoRoute(
        path: hiveTypes,
        builder: (context, state) => const HiveTypesPage(),
      ),
      GoRoute(
        path: editApiary,
        builder: (context, state) {
          // Accepts extra as either a String (apiaryId) or a Map with apiaryId
          final extra = state.extra;
          String? apiaryId;
          if (extra is String) {
            apiaryId = extra;
          } else if (extra is Map<String, dynamic>) {
            apiaryId = extra['apiaryId'] as String?;
          }
          return EditApiaryPage(
            apiaryId: apiaryId,
          );
        },
      ),
      GoRoute(
        path: editQueen,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final queenId = extra?['queenId'] as String?;
          final hideLocation = extra?['hideLocation'] as bool? ?? false;
          
          return EditQueenPage(
            queenId: queenId,
            hideLocation: hideLocation,
          );
        },
      ),      GoRoute(
        path: editQueenBreed,
        builder: (context, state) {
          final extra = state.extra as String?; // Now expects just the ID string
          
          return EditQueenBreedPage(
            breedId: extra,
          );
        },
      ),
      GoRoute(
        path: editHiveType,
        builder: (context, state) {
          final extra = state.extra as String?; // Now expects just the ID string
          
          return EditHiveTypePage(
            hiveTypeId: extra,
          );
        },
      ),      GoRoute(
        path: queenBreedDetail,
        builder: (context, state) {
          final extra = state.extra as String?; // Now expects just the ID string
          
          if (extra == null) {
            return const Scaffold(
              body: Center(child: Text('Breed ID not provided')),
            );
          }
          
          return QueenBreedDetailPage(breedId: extra);
        },
      ),
      GoRoute(
        path: queenDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final queenId = extra?['queenId'] as String?;
          
          if (queenId == null) {
            return const Scaffold(
              body: Center(child: Text('Queen ID not provided')),
            );
          }
          
          return QueenDetailPage(queenId: queenId);
        },
      ),
      GoRoute(
        path: hiveTypeDetail,
        builder: (context, state) {
          final extra = state.extra as String?; // Now expects just the ID string
          
          if (extra == null) {
            return const Scaffold(
              body: Center(child: Text('Hive Type ID not provided')),
            );
          }
          
          return HiveTypeDetailPage(hiveTypeId: extra);
        },
      ),
      GoRoute(
        path: editHive,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final hiveId = extra?['hiveId'] as String?;
          final hideLocation = extra?['hideLocation'] as bool? ?? false;
          final queenId = extra?['queenId'] as String?;

          return EditHivePage(
            hiveId: hiveId,
            hideLocation: hideLocation,
            queenId: queenId,
          );
        },
      ),
      GoRoute(
        path: apiaryDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final apiaryId = extra?['apiaryId'] as String?;
          
          if (apiaryId == null) {
            return const Scaffold(
              body: Center(child: Text('Apiary ID not provided')),
            );
          }
          
          return ApiaryDetailPage(apiaryId: apiaryId);
        },
      ),
      GoRoute(
        path: hiveDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final hiveId = extra?['hiveId'] as String?;
          
          if (hiveId == null) {
            return const Scaffold(
              body: Center(child: Text('Hive ID not provided')),
            );
          }
          
          return HiveDetailPage(hiveId: hiveId);
        },
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