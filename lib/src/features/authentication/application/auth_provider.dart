import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../domain/auth_state.dart';
import '../domain/auth_user.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    _tryRestoreSession();
    return const AuthState.initial();
  }

  Future<void> _tryRestoreSession() async {
    state = const AuthState.loading();

    final result = await _repository.tryRestoreSession();
    if (result != null) {
      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
      );
    } else {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> loginWithUniversalLogin() async {
    state = const AuthState.loading();

    try {
      final result = await _repository.loginWithUniversalLogin();
      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
      );
    } catch (e) {
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  Future<void> loginWithGoogle() async {
    state = const AuthState.loading();

    try {
      final result = await _repository.loginWithGoogle();
      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
      );
    } catch (e) {
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  Future<void> loginWithApple() async {
    state = const AuthState.loading();

    try {
      final result = await _repository.loginWithApple();
      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
      );
    } catch (e) {
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  Future<bool> startPhoneLogin({required String phoneNumber}) async {
    state = const AuthState.loading();

    try {
      await _repository.startPasswordlessWithPhone(phoneNumber: phoneNumber);
      state = const AuthState.unauthenticated();
      return true;
    } catch (e) {
      state = AuthState.error(_getErrorMessage(e));
      return false;
    }
  }

  Future<void> loginWithPhoneCode({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    state = const AuthState.loading();

    try {
      final result = await _repository.loginWithPhoneCode(
        phoneNumber: phoneNumber,
        verificationCode: verificationCode,
      );
      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
      );
    } catch (e) {
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();

    try {
      await _repository.logout();
    } catch (_) {
      // Continue even if logout fails
    }

    state = const AuthState.unauthenticated();
  }

  void clearError() {
    if (state.status == AuthStatus.error) {
      state = const AuthState.unauthenticated();
    }
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('cancelled') || errorStr.contains('canceled')) {
      return 'Login was cancelled';
    }
    if (errorStr.contains('invalid_otp') || errorStr.contains('invalid code')) {
      return 'Invalid verification code';
    }
    if (errorStr.contains('expired') && errorStr.contains('code')) {
      return 'Verification code expired. Please request a new one';
    }
    if (errorStr.contains('too_many_attempts')) {
      return 'Too many attempts. Please try again later';
    }
    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Network error. Please check your connection';
    }
    if (errorStr.contains('invalid') && errorStr.contains('phone')) {
      return 'Invalid phone number format';
    }

    return 'An error occurred. Please try again';
  }
}

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentAuthUserProvider = Provider<AuthUser?>((ref) {
  return ref.watch(authProvider).user;
});
