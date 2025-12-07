import 'package:flutter/foundation.dart';
import 'auth_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

@immutable
class AuthState {
  final AuthStatus status;
  final AuthUser? user;
  final String? accessToken;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.accessToken,
    this.errorMessage,
  });

  const AuthState.initial()
    : status = AuthStatus.initial,
      user = null,
      accessToken = null,
      errorMessage = null;

  const AuthState.loading()
    : status = AuthStatus.loading,
      user = null,
      accessToken = null,
      errorMessage = null;

  const AuthState.authenticated({
    required AuthUser this.user,
    required String this.accessToken,
  }) : status = AuthStatus.authenticated,
       errorMessage = null;

  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      user = null,
      accessToken = null,
      errorMessage = null;

  const AuthState.error(String message)
    : status = AuthStatus.error,
      user = null,
      accessToken = null,
      errorMessage = message;

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? accessToken,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          user == other.user &&
          accessToken == other.accessToken &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      status.hashCode ^
      user.hashCode ^
      accessToken.hashCode ^
      errorMessage.hashCode;
}
