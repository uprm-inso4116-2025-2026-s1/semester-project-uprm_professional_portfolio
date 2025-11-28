import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

import '../core/constants/app_constants.dart';
import '../core/cubits/auth/auth_cubit.dart';
import '../core/cubits/auth/auth_state.dart';
import '../features/auth/login/login_screen.dart';
import '../features/auth/signup/signup_screen.dart';
import '../features/welcome/welcome_screen.dart';
import '../features/main/main_screen.dart';
import '../features/profiles/recruiter_profile/recruiter_profile_screen.dart';
import '../features/profiles/jobseeker_profile/jobseeker_profile_screen.dart';
import '../features/chat/chat_room_page.dart';

// App router configuration
class AppRouter {
  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: AppConstants.loginRoute,
      refreshListenable: _GoRouterRefreshStream(authCubit.stream),
      redirect: (BuildContext context, GoRouterState state) {
        final authState = authCubit.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final currentLocation = state.matchedLocation;
        final targetLocation = state.uri.toString();

        final isLoggingIn = currentLocation == AppConstants.loginRoute ||
            currentLocation == AppConstants.signupRoute;
        final isGoingToProfile =
            targetLocation.startsWith(AppConstants.recruiterProfileRoute) ||
                targetLocation.startsWith(AppConstants.jobseekerProfileRoute);
        final isGoingToWelcome =
            targetLocation.startsWith(AppConstants.welcomeRoute);

        // If not authenticated and not on login/signup, redirect to login
        if (!isAuthenticated && !isLoggingIn) {
          return AppConstants.loginRoute;
        }

        // If authenticated and on login/signup, only redirect to main if NOT going to profile or welcome
        if (isAuthenticated &&
            isLoggingIn &&
            !isGoingToProfile &&
            !isGoingToWelcome) {
          return AppConstants.mainRoute;
        }

        return null; // No redirect needed
      },
      routes: [
        // Authentication routes
        GoRoute(
          path: AppConstants.loginRoute,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppConstants.signupRoute,
          builder: (context, state) => const SignupScreen(),
        ),

        // Welcome screen (after signup)
        GoRoute(
          path: AppConstants.welcomeRoute,
          builder: (context, state) => const WelcomeScreen(),
        ),

        // Main screen with bottom navigation
        GoRoute(
          path: AppConstants.mainRoute,
          builder: (context, state) {
            final indexParam = state.uri.queryParameters['tab'];
            final index = int.tryParse(indexParam ?? '0') ?? 0;
            return MainScreen(initialIndex: index);
          },
        ),

        // Chat room route for a specific conversation
        GoRoute(
          path: '/chat/:conversationId',
          builder: (context, state) {
            final conversationId = state.pathParameters['conversationId'] ?? '';
            return ChatRoomPage(conversationId: conversationId);
          },
        ),

        // Profile setup routes
        GoRoute(
          path: AppConstants.recruiterProfileRoute,
          builder: (context, state) => const RecruiterProfileScreen(),
        ),
        GoRoute(
          path: AppConstants.jobseekerProfileRoute,
          builder: (context, state) => const JobSeekerProfileScreen(),
        ),
      ],
    );
  }
}

// Helper class to refresh router when auth state changes
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<AuthState> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (_) => notifyListeners(),
        );
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
