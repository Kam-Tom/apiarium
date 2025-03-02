import 'package:apiarium/core/core.dart';
import 'package:apiarium/features/auth/auth.dart';
import 'package:apiarium/features/home/home.dart';
import 'package:apiarium/shared/layouts/main_layout.dart';
import 'package:go_router/go_router.dart';
class AppRouter {
  // Define route paths as constants
  static const String home = '/';
  static const String social = '/social';
  static const String shop = '/shop';
  static const String more = '/more';
  static const String report = '/report';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  
  final AuthBloc authBloc;
  
  AppRouter({required this.authBloc});

  // Create the router
  late final GoRouter router = GoRouter(
    routes: [
      // Public routes (accessible without authentication)
      GoRoute(
        path: signUp,
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: signIn,
        builder: (context, state) => const SignInPage(),
      ),
      
      // Shell route for home layout with bottom navigation
      ShellRoute(
        builder: (context, state, child) {
          // Determine the current index based on the path
          int currentIndex = 0;
          final String path = state.uri.path;
          
          if (path.startsWith(social)) {
            currentIndex = 1;
          } else if (path.startsWith(shop)) {
            currentIndex = 2;
          } else if (path.startsWith(more)) {
            currentIndex = 3;
          } else if (path.startsWith(report)) {
            currentIndex = 4; // Special case for report
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
          // GoRoute(
          //   path: social,
          //   builder: (context, state) => const SocialPage(), 
          // ),
          // GoRoute(
          //   path: raport,
          //   builder: (context, state) => const RaportPage(), 
          // ),
          // GoRoute(
          //   path: shop,
          //   builder: (context, state) => const ShopPage(), 
          // ),
          // GoRoute(
          //   path: more,
          //   builder: (context, state) => const MorePage(),
          //),
        ],
      ),
    ],
    refreshListenable: StreamToListenable([authBloc.stream]),
    redirect: (context, state) {
      final isAuthenticated = authBloc.state is Authenticated;
      final isUnauthenticated = authBloc.state is Unauthenticated;
      final isLoading = authBloc.state is AuthLoading || authBloc.state is AuthInitial;
      final isJustSignedUp = authBloc.state is SignedUp;
      
      final currentPath = state.uri.path;
      
      // Don't redirect while initializing or loading
      if (isLoading) return null;
      
      // Users who just signed up should be allowed to stay on the sign up page
      if (isJustSignedUp) return null;
      
      // Redirect unauthenticated users to auth page
      if (isUnauthenticated && currentPath != signIn && currentPath != signUp) {
        return signUp;
      } 
      
      // Redirect authenticated users to home if they're on the auth page
      if (isAuthenticated && (currentPath == signUp || currentPath == signIn)) {
        return home;
      }

      // No redirect
      return null;
    },
  );
}