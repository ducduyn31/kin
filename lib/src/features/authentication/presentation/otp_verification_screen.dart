import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../application/auth_provider.dart';
import '../domain/auth_state.dart';
import 'otp_input.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationScreen({super.key, required this.phoneNumber});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  static const Widget _loadingIndicator = SizedBox(
    height: 20,
    width: 20,
    child: CircularProgressIndicator(strokeWidth: 2),
  );

  final _otpKey = GlobalKey<OtpInputState>();

  String _otpCode = '';
  bool _isResending = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

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
      appBar: AppBar(title: Text(l10n.verifyCode)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.verificationCode,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.enterVerificationCodeSentTo(widget.phoneNumber),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OtpInput(
                key: _otpKey,
                length: 6,
                enabled: !authState.isLoading,
                onChanged: (code) {
                  setState(() {
                    _otpCode = code;
                  });
                },
                onCompleted: (code) {
                  debugPrint('[OtpVerificationScreen] OTP completed');
                  _verifyCode();
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: authState.isLoading || _otpCode.length < 6
                    ? null
                    : _verifyCode,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: authState.isLoading
                    ? _loadingIndicator
                    : Text(l10n.verifyCode),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: authState.isLoading || _isResending
                      ? null
                      : _resendCode,
                  child: _isResending
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.resendCode),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _verifyCode() async {
    final l10n = AppLocalizations.of(context)!;

    if (_otpCode.length < 6) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseEnterVerificationCode)));
      return;
    }

    debugPrint('[OtpVerificationScreen] Verifying code');
    await ref
        .read(authProvider.notifier)
        .loginWithPhoneCode(
          phoneNumber: widget.phoneNumber,
          verificationCode: _otpCode,
        );
  }

  Future<void> _resendCode() async {
    setState(() => _isResending = true);

    final success = await ref
        .read(authProvider.notifier)
        .startPhoneLogin(phoneNumber: widget.phoneNumber);

    if (!mounted) return;

    final l10n = AppLocalizations.of(context)!;
    setState(() => _isResending = false);

    if (success) {
      _otpKey.currentState?.clear();
      setState(() {
        _otpCode = '';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.verificationCodeResent)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToSendVerificationCode),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}
