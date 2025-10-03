import 'package:flutter/material.dart';
import 'routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'components/role_badge.dart';
import 'core/state/app_state.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/services/supabase_service.dart';
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
    return MaterialApp.router(
      title: 'UPRM Professional Portfolio',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,

      builder: (context, child) {
      if (!kIsWeb || child == null) return child ?? const SizedBox.shrink();
      return Stack(
        children: [
          child,
          const Positioned(top: 12, right: 12, child: RoleBadge()),
        ],
      );
    },
    );
  }
}
