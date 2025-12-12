import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/src/features/authentication/application/auth_provider.dart';
import 'package:kin/src/features/authentication/domain/auth_state.dart';
import 'package:kin/src/features/authentication/presentation/otp_input.dart';
import 'package:kin/src/features/authentication/presentation/otp_verification_screen.dart';
import 'package:kin/src/l10n/app_localizations.dart';
import 'package:kin/src/l10n/app_localizations_en.dart';

import '../../../../helpers/mocks/notifiers/auth.dart';

const _kTestPhoneNumber = '+15551234567';

void main() {
  group('OtpVerificationScreen', () {
    late MockAuthNotifier mockAuthNotifier;
    late AppLocalizations l10n;

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
      l10n = AppLocalizationsEn();
    });

    Widget buildTestWidget({
      String phoneNumber = _kTestPhoneNumber,
      AuthState? initialState,
    }) {
      if (initialState != null) {
        mockAuthNotifier.setInitialState(initialState);
      }

      return ProviderScope(
        overrides: [
          authProvider.overrideWith(() => mockAuthNotifier),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: OtpVerificationScreen(phoneNumber: phoneNumber),
        ),
      );
    }

    group('when initialized', () {
      testWidgets('should display phone number in subtitle', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.textContaining(_kTestPhoneNumber), findsOneWidget);
      });

      testWidgets('should display app bar title', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(l10n.verifyCode),
          ),
          findsOneWidget,
        );
      });

      testWidgets('should display OTP input widget', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(OtpInput), findsOneWidget);
      });

      testWidgets('should display Verify Code button', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(
          find.widgetWithText(FilledButton, l10n.verifyCode),
          findsOneWidget,
        );
      });

      testWidgets('should display Resend Code button', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(
          find.widgetWithText(TextButton, l10n.resendCode),
          findsOneWidget,
        );
      });
    });

    group('when code is incomplete', () {
      testWidgets('should have disabled Verify Code button', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, l10n.verifyCode),
        );

        expect(button.onPressed, isNull);
      });
    });

    group('when 6 digits are entered', () {
      Future<void> enterFullCode(WidgetTester tester) async {
        final textFields = find.byType(TextField);
        for (var i = 0; i < 6; i++) {
          await tester.tap(textFields.at(i));
          await tester.pump();
          await tester.enterText(textFields.at(i), '${i + 1}');
          await tester.pump();
        }
      }

      testWidgets('should have enabled Verify Code button', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await enterFullCode(tester);

        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, l10n.verifyCode),
        );

        expect(button.onPressed, isNotNull);
      });

      testWidgets('should auto-submit via onCompleted', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Paste 6 digits at once to trigger onCompleted
        await tester.tap(find.byType(TextField).first);
        await tester.pump();
        await tester.enterText(find.byType(TextField).first, '654321');
        await tester.pump();

        expect(mockAuthNotifier.loginWithPhoneCodeCalled, true);
        expect(mockAuthNotifier.lastVerificationCode, '654321');
      });
    });

    group('when Verify Code button is pressed', () {
      testWidgets('should call loginWithPhoneCode with correct parameters',
          (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // Enter 6 digits
        final textFields = find.byType(TextField);
        for (var i = 0; i < 6; i++) {
          await tester.tap(textFields.at(i));
          await tester.pump();
          await tester.enterText(textFields.at(i), '${i + 1}');
          await tester.pump();
        }

        await tester.tap(find.widgetWithText(FilledButton, l10n.verifyCode));
        await tester.pump();

        expect(mockAuthNotifier.loginWithPhoneCodeCalled, true);
        expect(mockAuthNotifier.lastPhoneNumber, _kTestPhoneNumber);
        expect(mockAuthNotifier.lastVerificationCode, '123456');
      });
    });

    group('when Resend Code button is pressed', () {
      testWidgets('should call startPhoneLogin with phone number',
          (tester) async {
        await tester.pumpWidget(buildTestWidget());

        await tester.tap(find.widgetWithText(TextButton, l10n.resendCode));
        await tester.pump();

        expect(mockAuthNotifier.startPhoneLoginCalled, true);
        expect(mockAuthNotifier.lastPhoneNumber, _kTestPhoneNumber);
      });

      group('when resend succeeds', () {
        setUp(() {
          mockAuthNotifier.shouldSucceed = true;
        });

        testWidgets('should show success snackbar', (tester) async {
          await tester.pumpWidget(buildTestWidget());
          await tester.tap(find.widgetWithText(TextButton, l10n.resendCode));
          await tester.pumpAndSettle();

          expect(find.text(l10n.verificationCodeResent), findsOneWidget);
        });
      });

      group('when resend fails', () {
        setUp(() {
          mockAuthNotifier.shouldSucceed = false;
        });

        testWidgets('should show error snackbar', (tester) async {
          await tester.pumpWidget(buildTestWidget());
          await tester.tap(find.widgetWithText(TextButton, l10n.resendCode));
          await tester.pumpAndSettle();

          expect(
            find.text(l10n.failedToSendVerificationCode),
            findsOneWidget,
          );
        });
      });
    });

    group('when auth state is loading', () {
      testWidgets('should disable OTP input', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(initialState: const AuthState.loading()),
        );

        final otpInput = tester.widget<OtpInput>(find.byType(OtpInput));

        expect(otpInput.enabled, false);
      });

      testWidgets('should show loading indicator in button', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(initialState: const AuthState.loading()),
        );

        expect(
          find.descendant(
            of: find.byType(FilledButton),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
      });

      testWidgets('should disable Verify Code button', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(initialState: const AuthState.loading()),
        );

        final button = tester.widget<FilledButton>(
          find.byType(FilledButton),
        );

        expect(button.onPressed, isNull);
      });

      testWidgets('should disable Resend Code button', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(initialState: const AuthState.loading()),
        );

        final button = tester.widget<TextButton>(
          find.widgetWithText(TextButton, l10n.resendCode),
        );

        expect(button.onPressed, isNull);
      });
    });
  });
}
