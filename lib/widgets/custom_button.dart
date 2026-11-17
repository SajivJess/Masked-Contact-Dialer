import 'package:flutter/material.dart';

/// A Material 3 styled button with configurable label, icon,
/// elevation, and ripple effect.
class CustomButton extends StatelessWidget {
  /// Button label text.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Called when the button is pressed.
  final VoidCallback? onPressed;

  /// Button elevation. Defaults to 2.
  final double elevation;

  /// Optional explicit background colour override.
  final Color? backgroundColor;

  /// Optional explicit foreground (text/icon) colour override.
  final Color? foregroundColor;

  const CustomButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.elevation = 2,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final style = ElevatedButton.styleFrom(
      elevation: elevation,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
    );

    if (icon != null) {
      return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: style,
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Text(label),
    );
  }
}
