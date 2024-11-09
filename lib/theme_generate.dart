import 'package:flutter/material.dart';

(ColorScheme light, ColorScheme dark) generateDynamicColourSchemes(
    ColorScheme lightDynamic, ColorScheme darkDynamic) {
  var lightBase = ColorScheme.fromSeed(seedColor: lightDynamic.secondary);
  var darkBase = ColorScheme.fromSeed(
      seedColor: darkDynamic.secondary, brightness: Brightness.dark);

  var lightAdditionalColours = _extractAdditionalColours(lightBase);
  var darkAdditionalColours = _extractAdditionalColours(darkBase);

  var lightScheme =
      _insertAdditionalColours(lightDynamic, lightAdditionalColours);
  var darkScheme = _insertAdditionalColours(darkDynamic, darkAdditionalColours);

  return (lightScheme, darkScheme);
}

List<Color> _extractAdditionalColours(ColorScheme scheme) => [
      scheme.surface,
      scheme.surfaceDim,
      scheme.surfaceBright,
      scheme.surfaceContainerLowest,
      scheme.surfaceContainerLow,
      scheme.surfaceContainer,
      scheme.surfaceContainerHigh,
      scheme.surfaceContainerHighest,
    ];

ColorScheme _insertAdditionalColours(
        ColorScheme scheme, List<Color> additionalColours) =>
    scheme.copyWith(
      surface: additionalColours[0],
      surfaceDim: additionalColours[1],
      surfaceBright: additionalColours[2],
      surfaceContainerLowest: additionalColours[3],
      surfaceContainerLow: additionalColours[4],
      surfaceContainer: additionalColours[5],
      surfaceContainerHigh: additionalColours[6],
      surfaceContainerHighest: additionalColours[7],
    );
