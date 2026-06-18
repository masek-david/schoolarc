import 'package:flutter/material.dart';

/// Spatial spring tokens are used for animations that move something on screen, for example the x and y position, rotation, size, rounded corners. This spring overshoots the final value and bounces into place.
enum SpatialMotion {
  /// Default
  ///
  /// Animations that partially cover the screen, such as bottom sheet and expanded navigation rail Opacity of the content within a  navigation rail
  defaultMotion(
    curve: Cubic(0.38, 1.21, 0.22, 1.00),
    duration: Duration(milliseconds: 500),
  ),

  /// Fast
  ///
  /// Small components, such as switches and buttons Color change of the switch handle
  fast(
    curve: Cubic(0.42, 1.67, 0.21, 0.90),
    duration: Duration(milliseconds: 350),
  ),

  /// Slow
  ///
  /// Full-screen animations, Full-screen content refresh
  slow(
    curve: Cubic(0.39, 1.29, 0.35, 0.98),
    duration: Duration(milliseconds: 650),
  ),
  ;

  const SpatialMotion({required this.curve, required this.duration});

  final Curve curve;
  final Duration duration;
}

/// Effects spring tokens are used to animate properties such as color and opacity animations, where there shouldn’t be any overshoot.
enum EffectsMotion {
  /// Default
  ///
  /// Opacity of the content within a navigation rail
  defaultMotion(
    curve: Cubic(0.34, 0.80, 0.34, 1.00),
    duration: Duration(milliseconds: 200),
  ),

  /// Fast
  ///
  /// Color change of the switch handle
  fast(
    curve: Cubic(0.31, 0.94, 0.34, 1.00),
    duration: Duration(milliseconds: 150),
  ),

  /// Slow
  ///
  /// Full-screen content refresh
  slow(
    curve: Cubic(0.34, 0.88, 0.34, 1.00),
    duration: Duration(milliseconds: 300),
  ),
  ;

  const EffectsMotion({required this.curve, required this.duration});

  final Curve curve;
  final Duration duration;
}

enum ButtonColorStyle { elevated, filled, tonal, outlined, text }

enum SplitButtonColorStyle { elevated, filled, tonal, outlined, text }

enum IconButtonColorStyle { filled, tonal, outlined, standard }

enum ButtonShape { round, square }

enum IconButtonWidth { narrow, defaultWidth, wide }

enum IconButtonSize {
  extraSmall(
    squareShape: .all(.circular(12)),
    pressedShape: .all(.circular(8)),
    defaultWidth: 32,
    narrowWidth: 28,
    wideWidth: 40,
    height: 32,
    iconSize: 20,
  ),
  small(
    squareShape: .all(.circular(12)),
    pressedShape: .all(.circular(8)),
    defaultWidth: 40,
    narrowWidth: 32,
    wideWidth: 52,
    height: 40,
    iconSize: 24,
  ),
  medium(
    squareShape: .all(.circular(16)),
    pressedShape: .all(.circular(12)),
    defaultWidth: 56,
    narrowWidth: 48,
    wideWidth: 72,
    height: 56,
    iconSize: 24,
  ),
  large(
    squareShape: .all(.circular(28)),
    pressedShape: .all(.circular(16)),
    defaultWidth: 96,
    narrowWidth: 64,
    wideWidth: 128,
    height: 96,
    iconSize: 32,
  ),
  extraLarge(
    squareShape: .all(.circular(28)),
    pressedShape: .all(.circular(16)),
    defaultWidth: 136,
    narrowWidth: 104,
    wideWidth: 184,
    height: 136,
    iconSize: 40,
  );

  const IconButtonSize({
    required this.squareShape,
    required this.pressedShape,
    required this.height,
    required this.defaultWidth,
    required this.narrowWidth,
    required this.wideWidth,
    required this.iconSize,
  });

  final BorderRadiusGeometry squareShape;
  final BorderRadiusGeometry pressedShape;
  final double height;
  final double defaultWidth;
  final double narrowWidth;
  final double wideWidth;
  final double iconSize;
}

enum ButtonSize {
  extraSmall(
    squareShape: .all(.circular(12)),
    shape: .all(.circular(16)),
    pressedShape: .all(.circular(8)),
    height: 32,
    padding: 12,
    iconSpacing: 4,
    fontSize: 14,
    iconSize: 20,
  ),
  small(
    squareShape: .all(.circular(12)),
    shape: .all(.circular(20)),
    pressedShape: .all(.circular(8)),
    height: 40,
    padding: 16,
    iconSpacing: 8,
    fontSize: 14,
    iconSize: 20,
  ),
  medium(
    squareShape: .all(.circular(16)),
    shape: .all(.circular(28)),
    pressedShape: .all(.circular(12)),
    height: 56,
    padding: 24,
    iconSpacing: 8,
    fontSize: 16,
    iconSize: 24,
  ),
  large(
    squareShape: .all(.circular(28)),
    shape: .all(.circular(48)),
    pressedShape: .all(.circular(12)),
    height: 96,
    padding: 48,
    iconSpacing: 12,
    fontSize: 24,
    iconSize: 32,
  ),
  extraLarge(
    squareShape: .all(.circular(28)),
    shape: .all(.circular(68)),
    pressedShape: .all(.circular(16)),
    height: 136,
    padding: 64,
    iconSpacing: 16,
    fontSize: 32,
    iconSize: 64,
  );

  const ButtonSize({
    required this.shape,
    required this.squareShape,
    required this.pressedShape,
    required this.height,
    required this.padding,
    required this.iconSpacing,
    required this.fontSize,
    required this.iconSize,
  });

  final BorderRadiusGeometry shape;
  final BorderRadiusGeometry squareShape;
  final BorderRadiusGeometry pressedShape;
  final double height;
  final double padding;
  final double iconSpacing;
  final double fontSize;
  final double iconSize;
}

enum SplitButtonSize {
  extraSmall(
    innerRadius: 4,
    pressedRadius: 8, //
    height: 32,
    paddingLeft: 12,
    paddingRight: 10,
    menuIconOffset: 1,
    menuPadding: 13,
    iconSpacing: 4,
    fontSize: 14, //
    iconSize: 20,
    menuIconSize: 22,
  ),
  small(
    innerRadius: 4,
    pressedRadius: 8, //
    height: 40,
    paddingLeft: 16,
    paddingRight: 12,
    menuIconOffset: 1,
    menuPadding: 13,
    iconSpacing: 8,
    fontSize: 14, //
    iconSize: 20,
    menuIconSize: 22,
  ),
  medium(
    innerRadius: 4,
    pressedRadius: 12, //
    height: 56,
    paddingLeft: 24,
    paddingRight: 24,
    menuIconOffset: 2,
    menuPadding: 15,
    iconSpacing: 8,
    fontSize: 16, //
    iconSize: 24,
    menuIconSize: 26,
  ),
  large(
    innerRadius: 8,
    pressedRadius: 12, //
    height: 96,
    paddingLeft: 48,
    paddingRight: 48,
    menuIconOffset: 3,
    menuPadding: 29,
    iconSpacing: 12,
    fontSize: 16, //
    iconSize: 32,
    menuIconSize: 38,
  ),
  extraLarge(
    innerRadius: 12,
    pressedRadius: 12, //
    height: 136,
    paddingLeft: 64,
    paddingRight: 64,
    menuIconOffset: 6,
    menuPadding: 43,
    iconSpacing: 16,
    fontSize: 16, //
    iconSize: 40,
    menuIconSize: 50,
  );

  const SplitButtonSize({
    required this.innerRadius,
    required this.pressedRadius,
    required this.height,
    required this.iconSpacing,
    required this.fontSize,
    required this.iconSize,
    required this.paddingLeft,
    required this.paddingRight,
    required this.menuPadding,
    required this.menuIconOffset,
    required this.menuIconSize,
  });

  final double innerRadius;
  final double pressedRadius;
  final double height;
  final double paddingLeft;
  final double paddingRight;

  /// padding of the right menu button
  final double menuPadding;

  /// the offset when unselected
  final double menuIconOffset;
  final double iconSpacing;
  final double fontSize;
  final double iconSize;
  final double menuIconSize;
}
