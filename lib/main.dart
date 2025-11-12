import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/cubits/auth/auth_cubit.dart';
import 'core/services/supabase_service.dart';
import 'core/services/storage_service.dart';
import 'core/services/auth_service.dart'; // Add this import
import 'components/role_badge.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Try to load .env if it exists, but don't fail if it doesn't
  // try {
  //   await dotenv.load(fileName: ".env");
  // } on Exception {
  //   debugPrint(
  //       '⚠️ .env file not found - running without environment configuration');
  // }

  // await SupabaseService.init();
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'core/constants/env.dart';
import 'core/constants/env_prod.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure runtime vars are present
  Env.assertProvided();

  // Initialize Supabase
  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create both services
    final storageService = StorageService();
    final authService = AuthService(); // Create AuthService instance
    final authCubit = AuthCubit(storageService, authService); // Pass both parameters

    return BlocProvider(
      create: (_) => authCubit..checkAuthStatus(),
      child: Builder(
        builder: (context) {
          // Get the authCubit from context to pass to router
          final cubit = context.read<AuthCubit>();

          return MaterialApp.router(
            title: 'UPRM Professional Portfolio',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: AppRouter.createRouter(cubit),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              if (!kIsWeb || child == null) {
                return child ?? const SizedBox.shrink();
              }
              return Stack(
                children: [
                  child,
                  const Positioned(top: 12, right: 12, child: RoleBadge()),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
  Widget build(BuildContext context) => MaterialApp.router( 
      title: 'UPRM Professional Portfolio',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }

