import 'package:go_router/go_router.dart';
import 'package:uprm_professional_portfolio/features/matches.dart';
import '../core/constants/app_constants.dart';
import '../features/auth/login/login_screen.dart';
import '../features/auth/signup/signup_screen.dart';
import '../features/profiles/recruiter_profile/recruiter_profile_screen.dart';
import '../features/profiles/jobseeker_profile/jobseeker_profile_screen.dart';

// App router configuration
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppConstants.signupRoute,
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

      // Profile setup routes
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
