import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../application/auth_provider.dart';
import '../domain/auth_state.dart';

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

  final _codeController = TextEditingController();

  bool _isCodeSent = false;
  String? _completePhoneNumber;
  String? _displayPhoneNumber;
  bool _isPhoneValid = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

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
                      : () => ref.read(authProvider.notifier).loginWithGoogle(),
                  icon: Icons.g_mobiledata_rounded,
                  label: 'Continue with Google',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                ),

                // Apple login button (only on Apple devices)
                if (_isAppleDevice) ...[
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

                // Phone number login
                if (!_isCodeSent) ...[
                  _buildPhoneInput(authState, colorScheme),
                ] else ...[
                  _buildCodeInput(authState, colorScheme),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput(AuthState authState, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntlPhoneField(
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
          initialCountryCode: _getInitialCountryCode(),
          disableLengthCheck: false,
          invalidNumberMessage: 'Invalid phone number',
          onChanged: (PhoneNumber phone) {
            setState(() {
              _completePhoneNumber = phone.completeNumber;
              _displayPhoneNumber = phone.completeNumber;
              _isPhoneValid = phone.isValidNumber();
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
          onPressed: authState.isLoading || !_isPhoneValid ? null : _sendCode,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: authState.isLoading
              ? _loadingIndicator
              : const Text('Send Verification Code'),
        ),
      ],
    );
  }

  Widget _buildCodeInput(AuthState authState, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter the verification code sent to $_displayPhoneNumber',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _codeController,
          decoration: const InputDecoration(
            labelText: 'Verification Code',
            hintText: '123456',
            prefixIcon: Icon(Icons.lock_outlined),
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onFieldSubmitted: (_) {
            if (!authState.isLoading) _verifyCode();
          },
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: authState.isLoading ? null : _verifyCode,
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
          child: authState.isLoading
              ? _loadingIndicator
              : const Text('Verify Code'),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: authState.isLoading ? null : _resendCode,
              child: const Text('Resend Code'),
            ),
            const SizedBox(width: 16),
            TextButton(
              onPressed: authState.isLoading ? null : _resetPhoneInput,
              child: const Text('Change Number'),
            ),
          ],
        ),
      ],
    );
  }

  String _getInitialCountryCode() {
    if (kIsWeb) return 'US';

    // Try to get locale-based country code
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final countryCode = locale.countryCode;

    if (countryCode != null && countryCode.isNotEmpty) {
      return countryCode;
    }

    return 'US';
  }

  void _resetPhoneInput() {
    setState(() {
      _isCodeSent = false;
      _codeController.clear();
      _completePhoneNumber = null;
      _displayPhoneNumber = null;
      _isPhoneValid = false;
    });
  }

  Future<void> _sendCode() async {
    if (_completePhoneNumber == null || _completePhoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    if (!_isPhoneValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid phone number')),
      );
      return;
    }

    final success = await ref
        .read(authProvider.notifier)
        .startPhoneLogin(phoneNumber: _completePhoneNumber!);

    if (success && mounted) {
      setState(() {
        _isCodeSent = true;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Verification code sent!')));
    }
  }

  Future<void> _resendCode() async {
    if (_completePhoneNumber == null) return;

    final success = await ref
        .read(authProvider.notifier)
        .startPhoneLogin(phoneNumber: _completePhoneNumber!);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification code resent!')),
      );
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the verification code')),
      );
      return;
    }

    if (_completePhoneNumber == null) return;

    await ref
        .read(authProvider.notifier)
        .loginWithPhoneCode(
          phoneNumber: _completePhoneNumber!,
          verificationCode: code,
        );
  }

  bool get _isAppleDevice {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isMacOS;
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
