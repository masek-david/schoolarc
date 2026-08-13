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
