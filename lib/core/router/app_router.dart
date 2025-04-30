import 'package:apiarium/core/core.dart';
import 'package:apiarium/features/auth/auth.dart';
import 'package:apiarium/features/home/home.dart';
import 'package:apiarium/features/raport/raport_page.dart';
import 'package:apiarium/features/managment/apiaries/apiaries_page.dart';
import 'package:apiarium/features/managment/edit_apiary/edit_apiary_page.dart';
import 'package:apiarium/features/managment/edit_hive/edit_hive_page.dart';
import 'package:apiarium/features/managment/edit_queen/edit_queen_page.dart';
import 'package:apiarium/features/managment/hives/hives_page.dart';
import 'package:apiarium/features/managment/managment_page.dart';
import 'package:apiarium/features/managment/queens/queens_page.dart';
import 'package:apiarium/shared/layouts/main_layout.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static const String home = '/';
  static const String social = '/social';
  static const String shop = '/shop';
  static const String more = '/more';
  static const String raport = '/raport';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String managment = '/managment';
  static const String statistics = '/statistics';
  static const String voiceControl = '/voice-control';
  static const String storage = '/storage';
  static const String calendar = '/calendar';
  static const String history = '/history';
  static const String queens = '/queens';
  static const String editQueen = '/edit-queen';
  static const String apiaries = '/apiaries';
  static const String editApiary = '/edit-apiary';
  static const String hives = '/hives';
  static const String editHive = '/edit-hive';

  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: signIn,
        builder: (context, state) => const SignInPage(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          int currentIndex = 0;
          final String path = state.uri.path;

          if (path.startsWith(social)) {
            currentIndex = 1;
          } else if (path.startsWith(shop)) {
            currentIndex = 2;
          } else if (path.startsWith(more)) {
            currentIndex = 3;
          }

          return MainLayout(
            currentIndex: currentIndex,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: home,
            builder: (context, state) => const HomePage(),
          ),
          // Other routes inside shell...
        ],
      ),

      GoRoute(
        path: raport,
        builder: (context, state) => const RaportPage(),
      ),

      GoRoute(
        path: managment,
        builder: (context, state) => const ManagmentPage(),
      ),
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
        builder: (context, state) {
          if (state.extra is String) {
            return EditHivePage(hiveId: state.extra as String);
          } else if (state.extra is Map) {
            final params = state.extra as Map;
            return EditHivePage(
              hiveId: params['hiveId'] as String?,
              skipSaving: params['skipSaving'] as bool? ?? false,
              hideLocation: params['hideLocation'] as bool? ?? false,
            );
          }
          return const EditHivePage();
        },
      ),
      GoRoute(
        path: queens,
        builder: (context, state) => const QueensPage(),
      ),
      GoRoute(
        path: editQueen,
        builder: (context, state) {
          if (state.extra is String) {
            return EditQueenPage(queenId: state.extra as String);
          } else if (state.extra is Map) {
            final params = state.extra as Map;
            return EditQueenPage(
              queenId: params['queenId'] as String?,
              skipSaving: params['skipSaving'] as bool? ?? false,
              hideLocation: params['hideLocation'] as bool? ?? false,
            );
          }
          return const EditQueenPage();
        },
      ),
    ],
    refreshListenable: StreamToListenable([authBloc.stream]),
    redirect: (context, state) {
      final isAuthenticated = authBloc.state is Authenticated;
      final isUnauthenticated = authBloc.state is Unauthenticated;
      final isLoading = authBloc.state is AuthLoading || authBloc.state is AuthInitial;
      final isJustSignedUp = authBloc.state is SignedUp;

      final currentPath = state.uri.path;

      if (isLoading) return null;
      if (isJustSignedUp) return null;

      if (isUnauthenticated && currentPath != signIn && currentPath != signUp) {
        return signUp;
      }

      if (isAuthenticated && (currentPath == signUp || currentPath == signIn)) {
        return home;
      }

      return null;
    },
  );
}