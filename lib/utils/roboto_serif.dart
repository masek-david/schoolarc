import 'package:flutter/material.dart';

/// Returns a Roboto Serif [TextStyle] with optional variable font axes.
///
/// - `width`: 50 – 150
/// - `weight`: 100 – 900
/// - `grade`: -50 – 100
TextStyle robotoSerif({
  double? size,
  Color? color,
  double? width,
  double? weight,
  double? grade,
}) {
  return TextStyle(
    fontFamily: 'Roboto Serif',
    fontSize: size,
    color: color,
    fontVariations: [
      if (width != null) FontVariation('wdth', width),
      if (weight != null) FontVariation('wght', weight),
      if (grade != null) FontVariation('GRAD', grade),
    ],
  );
}
