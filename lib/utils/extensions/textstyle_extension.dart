import 'package:flutter/material.dart';

extension BetterTextStyle on TextStyle {
  /// Returns a Nunito [TextStyle] with optional variable font axes.
  ///
  /// - `weight`: 200 – 1000
  TextStyle copyWithNunito({
    double? size,
    Color? color,
    double? weight,
  }) {
    return copyWith(
        fontSize: size,
        color: color,
        fontFamily: 'Nunito',
        fontVariations: [
          if (weight != null) FontVariation('wght', weight),
        ]);
  }
}
