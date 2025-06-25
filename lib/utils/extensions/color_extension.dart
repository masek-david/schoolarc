import 'package:flutter/material.dart';

extension BetterColors on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  /// returns lighter value if makeItLigher is true
  Color dynamicLighten({required bool makeItLighter, double amount = 0.5}) {
    assert(amount >= 0 && amount <= 1);

    if (makeItLighter) {
      return lighten(amount);
    }
    return darken(amount);
  }
}
