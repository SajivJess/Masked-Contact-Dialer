import 'package:flutter/material.dart';

/// A circular avatar with a gradient background generated from
/// the contact's [displayName] hash. Shows the first letter of
/// the display name in white.
class GradientAvatar extends StatelessWidget {
  /// The display name used to derive the gradient colours and
  /// the initial letter.
  final String displayName;

  /// Radius of the avatar circle. Defaults to 22.
  final double radius;

  const GradientAvatar({
    super.key,
    required this.displayName,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _gradientColors(displayName.hashCode);
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 0.85,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Derives two gradient colours from a hash code so each name
  /// gets a visually distinct but deterministic palette.
  static List<Color> _gradientColors(int hash) {
    final hue1 = (hash % 360).abs().toDouble();
    final hue2 = ((hash ~/ 360) % 360).abs().toDouble();
    return [
      HSLColor.fromAHSL(1.0, hue1, 0.65, 0.55).toColor(),
      HSLColor.fromAHSL(1.0, hue2, 0.65, 0.45).toColor(),
    ];
  }
}
