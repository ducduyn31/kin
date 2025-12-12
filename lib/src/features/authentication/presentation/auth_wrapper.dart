import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/auth_provider.dart';
import '../domain/auth_state.dart';
import 'login_screen.dart';

class AuthWrapper extends ConsumerWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return switch (authState.status) {
      AuthStatus.initial || AuthStatus.loading => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      AuthStatus.authenticated => child,
      AuthStatus.unauthenticated || AuthStatus.error => Navigator(
        onGenerateRoute: (_) =>
            MaterialPageRoute(builder: (_) => const LoginScreen()),
      ),
    };
  }
}
