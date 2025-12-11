import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/analytics_service.dart';
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

  Future<void> loginWithGoogle() async {
    state = const AuthState.loading();
    analytics.capture('login_started', {'method': 'google'});

    try {
      final result = await _repository.loginWithGoogle();
      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
      );
      analytics.capture('login_success', {'method': 'google'});
      analytics.identify(result.user.id);
    } catch (e) {
      analytics.capture('login_failed', {
        'method': 'google',
        'error': e.toString(),
      });
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  Future<void> loginWithApple() async {
    state = const AuthState.loading();
    analytics.capture('login_started', {'method': 'apple'});

    try {
      final result = await _repository.loginWithApple();
      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
      );
      analytics.capture('login_success', {'method': 'apple'});
      analytics.identify(result.user.id);
    } catch (e) {
      analytics.capture('login_failed', {
        'method': 'apple',
        'error': e.toString(),
      });
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  /// Initiates passwordless phone login by sending a verification code via SMS.
  ///
  /// Returns `true` if the code was sent successfully, `false` otherwise.
  /// On success, the user should be prompted to enter the verification code
  /// and then call [loginWithPhoneCode] to complete authentication.
  ///
  /// Note: This method intentionally does not set loading state to avoid
  /// triggering AuthWrapper to replace the LoginScreen during the async call.
  Future<bool> startPhoneLogin({required String phoneNumber}) async {
    debugPrint('[AuthProvider] startPhoneLogin called with: $phoneNumber');
    analytics.capture('phone_login_started');

    try {
      await _repository.startPasswordlessWithPhone(phoneNumber: phoneNumber);
      debugPrint('[AuthProvider] SMS sent successfully, returning true');
      analytics.capture('phone_login_code_sent');
      return true;
    } catch (e) {
      debugPrint('[AuthProvider] startPhoneLogin failed: $e');
      analytics.capture('phone_login_code_failed', {'error': e.toString()});
      return false;
    }
  }

  Future<void> loginWithPhoneCode({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    state = const AuthState.loading();
    analytics.capture('phone_login_verify_started');

    try {
      final result = await _repository.loginWithPhoneCode(
        phoneNumber: phoneNumber,
        verificationCode: verificationCode,
      );
      state = AuthState.authenticated(
        user: result.user,
        accessToken: result.accessToken,
      );
      analytics.capture('login_success', {'method': 'phone'});
      analytics.identify(result.user.id);
    } catch (e) {
      analytics.capture('login_failed', {
        'method': 'phone',
        'error': e.toString(),
      });
      state = AuthState.error(_getErrorMessage(e));
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    analytics.capture('logout');

    try {
      await _repository.logout();
    } catch (e) {
      debugPrint('[AuthProvider] Logout failed: $e');
      analytics.capture('logout_failed', {'error': e.toString()});
    }

    analytics.reset();
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
