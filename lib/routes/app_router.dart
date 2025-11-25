import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:uprm_professional_portfolio/features/matches.dart';
import '../core/constants/app_constants.dart';
import '../features/auth/login/login_screen.dart';
import '../features/auth/signup/signup_screen.dart';
import '../features/profiles/jobseeker_profile/jobseeker_profile_screen.dart';
import '../features/profiles/recruiter_profile/recruiter_profile_screen.dart';

// App router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    // React to Supabase auth changes (login/logout)
    refreshListenable: GoRouterRefreshStream(
      // Any event on this stream will cause GoRouter to reevaluate redirects
      Supabase.instance.client.auth.onAuthStateChange,
    ),

    // Start on login (your current behavior)
    initialLocation: AppConstants.loginRoute,

    // Basic auth guard
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final path = state.uri.path;

      final isAuthRoute = path == AppConstants.loginRoute ||
          path == AppConstants.signupRoute;

      // If logged in and trying to access /login or /signup → send to a private route
      if (session != null && isAuthRoute) {
        return AppConstants.recruiterProfileRoute;
      }

      // If not logged in and trying to hit a protected route → go to /login
      if (session == null && !isAuthRoute) {
        return AppConstants.loginRoute;
      }

      // No redirect needed
      return null;
    },

    routes: [
      // Authentication routes (public)
      GoRoute(
        path: AppConstants.loginRoute,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.signupRoute,
        builder: (context, state) => const SignupScreen(),
      ),

      // Profile setup routes (private)
      GoRoute(
        path: AppConstants.recruiterProfileRoute,
        builder: (context, state) => const RecruiterProfileScreen(),
      ),
      GoRoute(
        path: AppConstants.jobseekerProfileRoute,
        builder: (context, state) => const JobSeekerProfileScreen(),
      ),
      GoRoute(
        path: AppConstants.matchesScreenRoute,
        builder: (context, state) => const MatchesScreen(),
      ),

      // TODO: Add more routes as needed
      // - Dashboard
      // - Job listings
      // - Profile view
      // - Settings
    ],
  );
}

/// Helper so GoRouter can listen to a Stream and call notifyListeners()
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
