import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:school_manager/l10n/my_localization.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

class TaskPriority {
  late final int index;
  late final String name;
  late final Color color;
  late final String htmlIcon;

  TaskPriority(int index) {
    final loc = getLocalization();

    switch (index) {
      case 3:
        color = Colors.red;
        htmlIcon = '\uD83D\uDD34';
        name = loc.high;
        this.index = 3;
      case 2:
        color = Colors.orange;
        htmlIcon = '\uD83D\uDFE0';
        name = loc.medium;
        this.index = 2;
      case 1:
        color = Colors.green;
        htmlIcon = '\uD83D\uDFE2';
        name = loc.low;
        this.index = 1;
      default:
        color = Colors.blue;
        htmlIcon = '\uD83D\uDD35';
        name = loc.noPriority;
        this.index = 0;
    }
  }

  Color getColor(BuildContext context) {
    return color.harmonizeWith(Theme.of(context).colorScheme.primary);
  }

  Color getOnColor(BuildContext context) {
    return generateOnColor(
            color, Theme.brightnessOf(context) == Brightness.dark)
        .harmonizeWith(context.col.primary);
  }

  /// mixes the color of the priority with surface color of theme
  Color getContainerColor(BuildContext context, {bool subtle = false}) {
    final harmonized =
        color.harmonizeWith(Theme.of(context).colorScheme.primary);

    return Color.lerp(harmonized, Theme.of(context).colorScheme.surface,
        subtle ? 0.85 : 0.3)!;
  }

  /// mixes the color of the priority with onSurface color of theme
  Color getOnContainerColor(BuildContext context) {
    final harmonized =
        color.harmonizeWith(Theme.of(context).colorScheme.primary);

    return Color.lerp(
        harmonized, Theme.of(context).colorScheme.onSurface, 0.9)!;
  }

  Color getSurfaceColor(BuildContext context) {
    return generateSurfaceContainer(
            color, Theme.brightnessOf(context) == Brightness.dark)
        .harmonizeWith(context.col.primary);
  }

  Color getOnSurfaceColor(BuildContext context) {
    return generateOnSurfaceContainer(
            color, Theme.brightnessOf(context) == Brightness.dark)
        .harmonizeWith(context.col.primary);
  }
}

Color generateSurfaceContainer(Color seedColor, bool isDark) {
  final hct = Hct.fromInt(seedColor.toARGB32());
  final surfaceContainerTone = isDark ? 13.0 : 90.0;
  final safeChroma =
      hct.chroma.clamp(0, 10).toDouble(); // Lower chroma = less vibrance
  final adjusted = Hct.from(hct.hue, safeChroma, surfaceContainerTone);
  return Color(adjusted.toInt());
}

Color generateOnSurfaceContainer(Color seedColor, bool isDark) {
  final hct = Hct.fromInt(seedColor.toARGB32());
  final surfaceContainerTone = !isDark ? 45.0 : 80.0;
  final safeChroma =
      hct.chroma.clamp(0, 1000).toDouble(); // Lower chroma = less vibrance
  final adjusted = Hct.from(hct.hue, safeChroma, surfaceContainerTone);
  return Color(adjusted.toInt());
}

Color generateOnColor(Color seedColor, bool isDark) {
  final hct = Hct.fromInt(seedColor.toARGB32());
  final surfaceContainerTone = isDark ? 13.0 : 98.0;
  final safeChroma =
      hct.chroma.clamp(0, 30).toDouble(); // Lower chroma = less vibrance
  final adjusted = Hct.from(hct.hue, safeChroma, surfaceContainerTone);
  return Color(adjusted.toInt());
}
