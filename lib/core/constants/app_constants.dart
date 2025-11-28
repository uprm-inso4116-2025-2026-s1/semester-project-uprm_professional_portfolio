// App-wide constants
class AppConstants {
  // App Info
  static const String appName = 'UPRM Professional Portfolio';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://api.uprm-portfolio.com';
  static const Duration requestTimeout = Duration(seconds: 30);

  // Routes
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  static const String welcomeRoute = '/welcome';
  static const String mainRoute = '/main';
  static const String settingsRoute = '/settings';
  static const String recruiterProfileRoute = '/recruiter-profile';
  static const String jobseekerProfileRoute = '/jobseeker-profile';
  static const String matchesScreenRoute = '/matches';
  static const String conversationsRoute = '/conversations';

  // User Roles
  static const String recruiterRole = 'recruiter';
  static const String jobseekerRole = 'jobseeker';
  static const String studentRole = 'student';

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxBioLength = 500;

  // Forgot Password
  static const String forgotPasswordRoute = '/forgot-password';
  static const String resetPasswordRoute  = '/reset-password';
}
