import 'package:apiarium/features/auth/auth.dart';
import 'package:apiarium/features/home/home.dart';
import 'package:apiarium/features/managment/managment_page.dart';
import 'package:apiarium/features/managment/apiaries/apiaries_page.dart';
import 'package:apiarium/features/managment/hives/hives_page.dart';
import 'package:apiarium/features/managment/queens/queens_page.dart';
import 'package:apiarium/features/managment/hive_types/hive_types_page.dart';
import 'package:apiarium/features/managment/queen_breeds/queen_breeds_page.dart';
import 'package:apiarium/features/managment/edit_apiary/edit_apiary.dart';
import 'package:apiarium/features/managment/edit_queen/edit_queen.dart';
import 'package:apiarium/features/managment/edit_queen_breed/edit_queen_breed_page.dart';
import 'package:apiarium/features/managment/edit_hive_type/edit_hive_type_page.dart';
import 'package:apiarium/features/managment/queen_breed_detail/queen_breed_detail_page.dart';
import 'package:apiarium/features/managment/queen_detail/queen_detail_page.dart';
import 'package:apiarium/features/managment/hive_type_detail/hive_type_detail_page.dart';
import 'package:apiarium/features/managment/edit_hive/edit_hive.dart';
import 'package:apiarium/shared/layouts/main_layout.dart';
import 'package:apiarium/shared/services/auth_service.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        builder: (context, state) => const ManagmentPage(),
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
          final extra = state.extra as Map<String, dynamic>?;
          final breedId = extra?['breedId'] as String?;
          
          return EditQueenBreedPage(
            breedId: breedId,
          );
        },
      ),
      GoRoute(
        path: editHiveType,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final hiveTypeId = extra?['hiveTypeId'] as String?;
          
          return EditHiveTypePage(
            hiveTypeId: hiveTypeId,
          );
        },
      ),      GoRoute(
        path: queenBreedDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final breed = extra?['breed'] as QueenBreed?;
          
          if (breed == null) {
            return const Scaffold(
              body: Center(child: Text('Breed not found')),
            );
          }
          
          return QueenBreedDetailPage(breed: breed);
        },
      ),
      GoRoute(
        path: queenDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final queen = extra?['queen'] as Queen?;
          
          if (queen == null) {
            return const Scaffold(
              body: Center(child: Text('Queen not found')),
            );
          }
          
          return QueenDetailPage(queen: queen);
        },
      ),
      GoRoute(
        path: hiveTypeDetail,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final hiveType = extra?['hiveType'] as HiveType?;
          
          if (hiveType == null) {
            return const Scaffold(
              body: Center(child: Text('Hive Type not found')),
            );
          }
          
          return HiveTypeDetailPage(hiveType: hiveType);
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