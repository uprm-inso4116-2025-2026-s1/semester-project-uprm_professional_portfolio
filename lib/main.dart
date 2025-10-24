import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/cubits/auth/auth_cubit.dart';
import 'core/services/supabase_service.dart';
import 'core/services/storage_service.dart';
import 'components/role_badge.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Create StorageService and AuthCubit
    final storageService = StorageService();
    final authCubit = AuthCubit(storageService);

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
