import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInput extends StatefulWidget {
  const OtpInput({
    super.key,
    required this.length,
    required this.onCompleted,
    this.onChanged,
    this.enabled = true,
  });

  final int length;

  final ValueChanged<String> onCompleted;

  final ValueChanged<String>? onChanged;

  final bool enabled;

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get code => _controllers.map((c) => c.text).join();

  void clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
    _focusNodes.first.requestFocus();
  }

  void _onChanged(int index, String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');

    // Handle paste (multiple digits)
    if (digits.length > 1) {
      _fillCode(digits.substring(0, digits.length.clamp(0, widget.length)));
      return;
    }

    // Ensure only single digit is stored
    if (digits.length == 1) {
      _controllers[index].text = digits;
      _controllers[index].selection = TextSelection.fromPosition(
        const TextPosition(offset: 1),
      );
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }

    _notifyChange();
  }

  void _fillCode(String code) {
    for (var i = 0; i < widget.length && i < code.length; i++) {
      _controllers[i].text = code[i];
    }
    _focusNodes.last.unfocus();
    _notifyChange();
  }

  void _notifyChange() {
    final currentCode = code;
    widget.onChanged?.call(currentCode);

    if (currentCode.length == widget.length) {
      widget.onCompleted(currentCode);
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return;

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
        _notifyChange();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (index) {
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
          child: SizedBox(
            width: 48,
            height: 56,
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) => _onKeyEvent(index, event),
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                enabled: widget.enabled,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: widget.length,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: widget.enabled
                      ? colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        )
                      : colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.3,
                        ),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) => _onChanged(index, value),
              ),
            ),
          ),
        );
      }),
    );
  }
}
