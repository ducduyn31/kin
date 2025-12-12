import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kin/src/features/authentication/application/auth_provider.dart';
import 'package:kin/src/features/authentication/domain/auth_state.dart';

class MockAuthNotifier extends Notifier<AuthState> implements AuthNotifier {
  AuthState _state = const AuthState.unauthenticated();
  bool loginWithPhoneCodeCalled = false;
  bool startPhoneLoginCalled = false;
  String? lastPhoneNumber;
  String? lastVerificationCode;
  bool shouldSucceed = true;

  @override
  AuthState build() => _state;

  void setState(AuthState newState) {
    _state = newState;
    ref.notifyListeners();
  }

  void setInitialState(AuthState state) {
    _state = state;
  }

  void reset() {
    _state = const AuthState.unauthenticated();
    loginWithPhoneCodeCalled = false;
    startPhoneLoginCalled = false;
    lastPhoneNumber = null;
    lastVerificationCode = null;
    shouldSucceed = true;
  }

  @override
  Future<bool> startPhoneLogin({required String phoneNumber}) async {
    startPhoneLoginCalled = true;
    lastPhoneNumber = phoneNumber;
    return shouldSucceed;
  }

  @override
  Future<void> loginWithPhoneCode({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    loginWithPhoneCodeCalled = true;
    lastPhoneNumber = phoneNumber;
    lastVerificationCode = verificationCode;
  }

  @override
  void clearError() {
    if (_state.status == AuthStatus.error) {
      setState(const AuthState.unauthenticated());
    }
  }

  @override
  Future<void> loginWithApple() async {}

  @override
  Future<void> loginWithGoogle() async {}

  @override
  Future<void> logout() async {}
}
