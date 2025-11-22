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

/// Returns a Google Sans Flex [TextStyle] with optional variable font axes.
///
/// - `width`: 25 – 151
/// - `weight`: 1 – 1000
/// - `grade`: 0 – 100
/// - `sland`: -10 – 0
/// - `roundness`: 0 – 100
TextStyle googleSansFlex({
  double? size,
  Color? color,
  double? width,
  double? weight,
  double? grade,
  bool? opticalSize,
  double? slant,
  double? roundness,
}) {
  return TextStyle(
    fontFamily: 'Google Sans Flex',
    fontSize: size,
    color: color,
    fontVariations: [
      if (width != null) FontVariation('wdth', width),
      if (weight != null) FontVariation('wght', weight),
      if (grade != null) FontVariation('GRAD', grade),
      if (opticalSize != null) FontVariation('opsz', opticalSize ? 1.0 : 0.0),
      if (slant != null) FontVariation('slnt', slant),
      if (roundness != null) FontVariation('ROND', roundness),
    ],
  );
}
