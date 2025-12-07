import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/config/env.dart';
import 'src/constants/app_theme.dart';
import 'src/features/authentication/presentation/auth_wrapper.dart';
import 'src/routing/app_router.dart';

void main() {
  if (kDebugMode && Env.enableDebugLogging) {
    debugPrint('Environment: ${Env.environment}');
  }

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
      home: AuthWrapper(
        child: Navigator(onGenerateRoute: AppRouter.onGenerateRoute),
      ),
    );
  }
}
