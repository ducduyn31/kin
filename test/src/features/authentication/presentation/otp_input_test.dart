import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kin/src/features/authentication/presentation/otp_input.dart';

void main() {
  group('OtpInput', () {
    Widget buildTestWidget({
      int length = 6,
      bool enabled = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: OtpInput(
            length: length,
            enabled: enabled,
            onCompleted: (_) {},
            onChanged: (_) {},
          ),
        ),
      );
    }

    group('when initialized', () {
      testWidgets('should render 6 text fields by default', (tester) async {
        await tester.pumpWidget(buildTestWidget(length: 6));

        expect(find.byType(TextField), findsNWidgets(6));
      });

      testWidgets('should render 4 text fields when length is 4',
          (tester) async {
        await tester.pumpWidget(buildTestWidget(length: 4));

        expect(find.byType(TextField), findsNWidgets(4));
      });

      group('when enabled is true', () {
        testWidgets('should have enabled text fields', (tester) async {
          await tester.pumpWidget(buildTestWidget(enabled: true));

          final textField =
              tester.widget<TextField>(find.byType(TextField).first);

          expect(textField.enabled, true);
        });
      });

      group('when enabled is false', () {
        testWidgets('should have disabled text fields', (tester) async {
          await tester.pumpWidget(buildTestWidget(enabled: false));

          final textField =
              tester.widget<TextField>(find.byType(TextField).first);

          expect(textField.enabled, false);
        });
      });
    });

    group('when entering digits', () {
      group('when a single digit is entered', () {
        testWidgets('should display the digit in the text field', (tester) async {
          await tester.pumpWidget(buildTestWidget());
          await tester.tap(find.byType(TextField).first);
          await tester.pump();
          await tester.enterText(find.byType(TextField).first, '1');
          await tester.pump();

          final textField =
              tester.widget<TextField>(find.byType(TextField).first);

          expect(textField.controller?.text, '1');
        });

        testWidgets('should move focus to next field', (tester) async {
          await tester.pumpWidget(buildTestWidget());
          await tester.tap(find.byType(TextField).first);
          await tester.pump();
          await tester.enterText(find.byType(TextField).first, '1');
          await tester.pump();

          final secondTextField =
              tester.widget<TextField>(find.byType(TextField).at(1));

          expect(secondTextField.focusNode?.hasFocus, true);
        });
      });

      group('when all digits are entered', () {
        testWidgets('should display all digits in text fields', (tester) async {
          await tester.pumpWidget(buildTestWidget(length: 4));
          final textFields = find.byType(TextField);

          for (var i = 0; i < 4; i++) {
            await tester.tap(textFields.at(i));
            await tester.pump();
            await tester.enterText(textFields.at(i), '${i + 1}');
            await tester.pump();
          }

          for (var i = 0; i < 4; i++) {
            final textField = tester.widget<TextField>(textFields.at(i));
            expect(textField.controller?.text, '${i + 1}');
          }
        });
      });

      group('when pasting multiple digits', () {
        testWidgets('should fill all fields with pasted digits', (tester) async {
          await tester.pumpWidget(buildTestWidget(length: 6));
          await tester.tap(find.byType(TextField).first);
          await tester.pump();
          await tester.enterText(find.byType(TextField).first, '123456');
          await tester.pump();

          final textFields = find.byType(TextField);
          for (var i = 0; i < 6; i++) {
            final textField = tester.widget<TextField>(textFields.at(i));
            expect(textField.controller?.text, '${i + 1}');
          }
        });
      });

      group('when non-numeric input is entered', () {
        testWidgets('should filter out non-numeric characters', (tester) async {
          await tester.pumpWidget(buildTestWidget());
          await tester.tap(find.byType(TextField).first);
          await tester.pump();

          await tester.enterText(find.byType(TextField).first, 'a');
          await tester.pump();

          final textField =
              tester.widget<TextField>(find.byType(TextField).first);

          expect(textField.controller?.text, isEmpty);
        });
      });
    });

    group('when pressing backspace', () {
      group('when current field is empty', () {
        testWidgets('should move focus to previous field and clear it',
            (tester) async {
          await tester.pumpWidget(buildTestWidget(length: 4));
          final textFields = find.byType(TextField);

          // Enter a digit in first field
          await tester.tap(textFields.at(0));
          await tester.pump();
          await tester.enterText(textFields.at(0), '1');
          await tester.pump();

          // Now on second field, press backspace
          await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
          await tester.pump();

          final state = tester.state<OtpInputState>(find.byType(OtpInput));

          expect(state.code, isEmpty);
        });
      });
    });

    group('when clear() is called', () {
      testWidgets('should clear all text fields', (tester) async {
        await tester.pumpWidget(buildTestWidget(length: 4));
        final textFields = find.byType(TextField);

        // Enter some digits
        for (var i = 0; i < 4; i++) {
          await tester.tap(textFields.at(i));
          await tester.pump();
          await tester.enterText(textFields.at(i), '${i + 1}');
          await tester.pump();
        }

        final state = tester.state<OtpInputState>(find.byType(OtpInput));
        state.clear();
        await tester.pump();

        for (var i = 0; i < 4; i++) {
          final textField = tester.widget<TextField>(textFields.at(i));
          expect(textField.controller?.text, isEmpty);
        }
      });
    });

  });
}
