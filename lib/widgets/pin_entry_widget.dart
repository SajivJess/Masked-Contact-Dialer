import 'package:flutter/material.dart';

/// A numeric keypad with dot indicators for PIN input.
///
/// Displays filled/empty dots based on the current input length and
/// calls [onCompleted] when the PIN reaches [pinLength] digits.
class PinEntryWidget extends StatefulWidget {
  /// Number of digits required for a complete PIN.
  final int pinLength;

  /// Called with the full PIN string once [pinLength] digits are entered.
  final ValueChanged<String> onCompleted;

  /// Optional title displayed above the dot indicators.
  final String? title;

  const PinEntryWidget({
    super.key,
    this.pinLength = 4,
    required this.onCompleted,
    this.title,
  });

  @override
  State<PinEntryWidget> createState() => _PinEntryWidgetState();
}

class _PinEntryWidgetState extends State<PinEntryWidget> {
  String _pin = '';

  void _onDigit(String digit) {
    if (_pin.length >= widget.pinLength) return;
    setState(() {
      _pin += digit;
    });
    if (_pin.length == widget.pinLength) {
      widget.onCompleted(_pin);
    }
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() {
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  /// Resets the entered PIN (useful after a failed attempt).
  void clear() {
    setState(() {
      _pin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
        ],
        // ── Dot indicators ──────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.pinLength, (index) {
            final filled = index < _pin.length;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: filled
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 40),
        // ── Numeric keypad ──────────────────────────────────────
        _buildKeypad(theme),
      ],
    );
  }

  Widget _buildKeypad(ThemeData theme) {
    const digits = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'backspace'],
    ];

    return Column(
      children: digits.map((row) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: row.map((key) {
            if (key.isEmpty) {
              return const SizedBox(width: 80, height: 64);
            }
            if (key == 'backspace') {
              return _KeypadButton(
                onTap: _onBackspace,
                child: Icon(
                  Icons.backspace_outlined,
                  color: theme.colorScheme.onSurface,
                ),
              );
            }
            return _KeypadButton(
              onTap: () => _onDigit(key),
              child: Text(
                key,
                style: theme.textTheme.headlineSmall,
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

/// A single keypad button with an ink ripple.
class _KeypadButton extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;

  const _KeypadButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 64,
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: onTap,
        child: Center(child: child),
      ),
    );
  }
}
