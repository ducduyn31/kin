import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'src/constants/app_theme.dart';
import 'src/routing/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KinApp(),
    ),
  );
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
      initialRoute: AppRouter.conversations,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
