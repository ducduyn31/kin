import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/config/env.dart';
import 'src/constants/app_theme.dart';
import 'src/features/authentication/presentation/auth_wrapper.dart';
import 'src/routing/app_router.dart';
import 'src/services/analytics_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode && Env.enableDebugLogging) {
    debugPrint('Environment: ${Env.environment}');
  }

  await analytics.initialize();

  runApp(const ProviderScope(child: KinApp()));
}

class KinApp extends StatelessWidget {
  const KinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      builder: (context, child) => AuthWrapper(child: child!),
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
    );
  }
}
