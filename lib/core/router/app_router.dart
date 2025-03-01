import 'package:apiarium/features/auth/auth.dart';
import 'package:apiarium/features/home/home.dart';
import 'package:go_router/go_router.dart';
import 'package:apiarium/core/core.dart';

class AppRouter {
  // Define route paths as constants
  static const String home = '/';
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
      // Protected routes (require authentication)
      GoRoute(
        path: home,
        builder: (context, state) => const HomePage(),
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
      // to see verification instructions, or they might be automatically redirected
      // to sign in page by the UI
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