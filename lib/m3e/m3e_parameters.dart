import 'package:flutter/material.dart';

/// Spatial spring tokens are used for animations that move something on screen, for example the x and y position, rotation, size, rounded corners. This spring overshoots the final value and bounces into place.
enum SpatialMotion {
  /// Default
  ///
  /// Animations that partially cover the screen, such as bottom sheet and  expanded navigation rail	Opacity of the content within a  navigation rail
  defaultMotion(
    curve: Cubic(0.38, 1.21, 0.22, 1.00),
    duration: Duration(milliseconds: 500),
  ),

  /// Fast
  ///
  /// Small components, such as switches and  buttons	Color change of the switch handle
  fast(
    curve: Cubic(0.42, 1.67, 0.21, 0.90),
    duration: Duration(milliseconds: 350),
  ),

  /// Slow
  ///
  /// Full-screen animations	Full-screen content refresh
  slow(
    curve: Cubic(0.39, 1.29, 0.35, 0.98),
    duration: Duration(milliseconds: 650),
  ),
  ;

  const SpatialMotion({required this.curve, required this.duration});

  final Curve curve;
  final Duration duration;
}

enum ButtonColorStyle { elevated, filled, tonal, outlined, text }

enum IconButtonColorStyle { filled, tonal, outlined, standard }

enum ButtonShape { round, square }

enum IconButtonWidth { narrow, defaultWidth, wide }

enum IconButtonSize {
  extraSmall(
    radius: 12,
    pressedRadius: 8,
    defaultWidth: 32,
    narrowWidth: 28,
    wideWidth: 40,
    height: 32,
    iconSize: 20,
  ),
  small(
    radius: 12,
    pressedRadius: 8,
    defaultWidth: 40,
    narrowWidth: 32,
    wideWidth: 52,
    height: 40,
    iconSize: 24,
  ),
  medium(
    radius: 16,
    pressedRadius: 12,
    defaultWidth: 56,
    narrowWidth: 48,
    wideWidth: 72,
    height: 56,
    iconSize: 24,
  ),
  large(
    radius: 28,
    pressedRadius: 16,
    defaultWidth: 96,
    narrowWidth: 64,
    wideWidth: 128,
    height: 96,
    iconSize: 32,
  ),
  extraLarge(
    radius: 28,
    pressedRadius: 16,
    defaultWidth: 136,
    narrowWidth: 104,
    wideWidth: 184,
    height: 136,
    iconSize: 40,
  )
  ;

  const IconButtonSize({
    required this.radius,
    required this.pressedRadius,
    required this.height,
    required this.defaultWidth,
    required this.narrowWidth,
    required this.wideWidth,
    required this.iconSize,
  });

  final double radius;
  final double pressedRadius;
  final double height;
  final double defaultWidth;
  final double narrowWidth;
  final double wideWidth;
  final double iconSize;
}

enum ButtonSize {
  extraSmall(
    radius: 12,
    pressedRadius: 8,
    height: 32,
    padding: 12,
    iconPadding: 4,
    fontSize: 14,
    iconSize: 20,
  ),
  small(
    radius: 12,
    pressedRadius: 8,
    height: 40,
    padding: 16,
    iconPadding: 8,
    fontSize: 14,
    iconSize: 20,
  ),
  medium(
    radius: 16,
    pressedRadius: 12,
    height: 56,
    padding: 24,
    iconPadding: 8,
    fontSize: 16,
    iconSize: 24,
  ),
  large(
    radius: 28,
    pressedRadius: 16,
    height: 96,
    padding: 48,
    iconPadding: 12,
    fontSize: 24,
    iconSize: 32,
  ),
  extraLarge(
    radius: 28,
    pressedRadius: 16,
    height: 136,
    padding: 64,
    iconPadding: 16,
    fontSize: 32,
    iconSize: 64,
  )
  ;

  const ButtonSize({
    required this.radius,
    required this.pressedRadius,
    required this.height,
    required this.padding,
    required this.iconPadding,
    required this.fontSize,
    required this.iconSize,
  });

  final double radius;
  final double pressedRadius;
  final double height;
  final double padding;
  final double iconPadding;
  final double fontSize;
  final double iconSize;
}
