import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../application/auth_provider.dart';
import '../domain/auth_state.dart';
import 'otp_verification_screen.dart';

bool get _isApplePlatform => Platform.isIOS;

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  static const Widget _loadingIndicator = SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );

  bool _isSendingCode = false;
  String? _completePhoneNumber;
  bool _isPhoneValid = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;

    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo/title
                Icon(
                  Icons.people_alt_rounded,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Kin',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stay connected with friends & family',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 48),

                // Google login button
                _SocialLoginButton(
                  onPressed: authState.isLoading
                      ? null
                      : () =>
                          ref.read(authProvider.notifier).loginWithGoogle(),
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                ),

                // Apple login button (only on Apple devices)
                if (_isApplePlatform) ...[
                  const SizedBox(height: 12),
                  _SocialLoginButton(
                    onPressed: authState.isLoading
                        ? null
                        : () =>
                            ref.read(authProvider.notifier).loginWithApple(),
                    icon: Icons.apple_rounded,
                    label: 'Continue with Apple',
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                ],
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Phone number input
                IntlPhoneField(
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  initialCountryCode: _getInitialCountryCode(),
                  disableLengthCheck: false,
                  invalidNumberMessage: 'Invalid phone number',
                  onChanged: (PhoneNumber phone) {
                    bool isValid;
                    try {
                      isValid = phone.isValidNumber();
                    } catch (_) {
                      isValid = false;
                    }
                    setState(() {
                      _completePhoneNumber = phone.completeNumber;
                      _isPhoneValid = isValid;
                    });
                  },
                  onCountryChanged: (country) {
                    setState(() {
                      _isPhoneValid = false;
                    });
                  },
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isSendingCode || !_isPhoneValid || authState.isLoading
                      ? null
                      : _sendCode,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _isSendingCode
                      ? _loadingIndicator
                      : const Text('Send Verification Code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitialCountryCode() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final countryCode = locale.countryCode;

    if (countryCode != null && countryCode.isNotEmpty) {
      return countryCode;
    }

    return 'US';
  }

  Future<void> _sendCode() async {
    debugPrint('[LoginScreen] _sendCode called for: $_completePhoneNumber');
    setState(() => _isSendingCode = true);

    final success = await ref
        .read(authProvider.notifier)
        .startPhoneLogin(phoneNumber: _completePhoneNumber!);

    debugPrint('[LoginScreen] _sendCode result: $success, mounted: $mounted');
    if (!mounted) return;

    setState(() => _isSendingCode = false);

    if (success) {
      debugPrint('[LoginScreen] Navigating to OTP screen');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code sent!')),
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OtpVerificationScreen(
            phoneNumber: _completePhoneNumber!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to send verification code'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class _SocialLoginButton extends StatelessWidget {
  const _SocialLoginButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: foregroundColor),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}
