import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/auth_user.dart';
import 'auth0_config.dart';

class AuthRepository {
  final Auth0 _auth0;
  final FlutterSecureStorage _secureStorage;

  static const _refreshTokenKey = 'auth0_refresh_token';

  AuthRepository({Auth0? auth0, FlutterSecureStorage? secureStorage})
    : _auth0 = auth0 ?? Auth0(Auth0Config.domain, Auth0Config.clientId),
      _secureStorage = secureStorage ?? const FlutterSecureStorage();

  Future<AuthResult> loginWithGoogle() async {
    final credentials = await _auth0
        .webAuthentication(scheme: Auth0Config.scheme)
        .login(
          scopes: Auth0Config.scopes.split(' ').toSet(),
          audience: Auth0Config.audience,
          parameters: {'connection': 'google-oauth2'},
        );

    await _saveRefreshToken(credentials.refreshToken);

    return AuthResult(
      user: AuthUser.fromAuth0(credentials.user.toMap()),
      accessToken: credentials.accessToken,
    );
  }

  Future<AuthResult> loginWithApple() async {
    final credentials = await _auth0
        .webAuthentication(scheme: Auth0Config.scheme)
        .login(
          scopes: Auth0Config.scopes.split(' ').toSet(),
          audience: Auth0Config.audience,
          parameters: {'connection': 'apple'},
        );

    await _saveRefreshToken(credentials.refreshToken);

    return AuthResult(
      user: AuthUser.fromAuth0(credentials.user.toMap()),
      accessToken: credentials.accessToken,
    );
  }

  /// Start passwordless login with phone number (sends SMS code)
  Future<void> startPasswordlessWithPhone({required String phoneNumber}) async {
    debugPrint('[Auth] Starting passwordless SMS login for: $phoneNumber');
    try {
      await _auth0.api.startPasswordlessWithPhoneNumber(
        phoneNumber: phoneNumber,
        passwordlessType: PasswordlessType.code,
      );
      debugPrint('[Auth] SMS code sent successfully');
    } catch (e) {
      debugPrint('[Auth] Failed to send SMS code: $e');
      rethrow;
    }
  }

  /// Complete passwordless login with phone number and verification code
  Future<AuthResult> loginWithPhoneCode({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    final credentials = await _auth0.api.loginWithSmsCode(
      phoneNumber: phoneNumber,
      verificationCode: verificationCode,
      scopes: Auth0Config.scopes.split(' ').toSet(),
      audience: Auth0Config.audience,
    );

    await _saveRefreshToken(credentials.refreshToken);

    final userProfile = await _auth0.api.userProfile(
      accessToken: credentials.accessToken,
    );

    return AuthResult(
      user: AuthUser.fromAuth0(userProfile.toMap()),
      accessToken: credentials.accessToken,
    );
  }

  /// Logout and clear stored credentials
  Future<void> logout() async {
    try {
      await _auth0.webAuthentication(scheme: Auth0Config.scheme).logout();
    } catch (e) {
      debugPrint('[AuthRepository] Web logout failed: $e');
    }

    await _clearRefreshToken();
  }

  /// Try to restore session from stored refresh token
  Future<AuthResult?> tryRestoreSession() async {
    final refreshToken = await _getRefreshToken();
    if (refreshToken == null) {
      return null;
    }

    try {
      final credentials = await _auth0.api.renewCredentials(
        refreshToken: refreshToken,
      );

      await _saveRefreshToken(credentials.refreshToken);

      final userProfile = await _auth0.api.userProfile(
        accessToken: credentials.accessToken,
      );

      return AuthResult(
        user: AuthUser.fromAuth0(userProfile.toMap()),
        accessToken: credentials.accessToken,
      );
    } catch (_) {
      // Refresh token is invalid, clear it
      await _clearRefreshToken();
      return null;
    }
  }

  /// Check if there's a stored refresh token
  Future<bool> hasStoredCredentials() async {
    final token = await _getRefreshToken();
    return token != null;
  }

  Future<void> _saveRefreshToken(String? token) async {
    if (token != null) {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
    }
  }

  Future<String?> _getRefreshToken() async {
    return _secureStorage.read(key: _refreshTokenKey);
  }

  Future<void> _clearRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }
}

class AuthResult {
  final AuthUser user;
  final String accessToken;

  const AuthResult({required this.user, required this.accessToken});
}
