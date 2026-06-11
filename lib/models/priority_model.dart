import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/hct/hct.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class TaskPriority {
  final int index;
  final String htmlIcon;
  final Color color;

  const TaskPriority(this.index)
    : htmlIcon = index == 3
          ? '\uD83D\uDD34'
          : index == 2
          ? '\uD83D\uDFE0'
          : index == 1
          ? '\uD83D\uDFE2'
          : '\uD83D\uDD35',
      color = index == 3
          ? const Color(0xFFF44336)
          : index == 2
          ? const Color(0xFFFF9800)
          : index == 1
          ? const Color(0xFF4CAF50)
          : const Color(0xFF2196F3);

  String name(BuildContext context) {
    return context.loc.priority(index.toString());
  }

  Color getColor(BuildContext context) {
    return color.harmonizeWith(Theme.of(context).colorScheme.primary);
  }

  Color getOnColor(BuildContext context) {
    return generateOnColor(
      color,
      Theme.brightnessOf(context) == Brightness.dark,
    ).harmonizeWith(context.col.primary);
  }

  /// mixes the color of the priority with surface color of theme
  Color getContainerColor(BuildContext context, {bool subtle = false}) {
    final harmonized = color.harmonizeWith(
      Theme.of(context).colorScheme.primary,
    );

    return Color.lerp(
      harmonized,
      Theme.of(context).colorScheme.surface,
      subtle ? 0.9 : 0.3,
    )!;
  }

  /// mixes the color of the priority with onSurface color of theme
  Color getOnContainerColor(BuildContext context, {bool subtle = false}) {
    final harmonized = color.harmonizeWith(
      Theme.of(context).colorScheme.primary,
    );

    if (subtle) {
      return Color.lerp(
        harmonized,
        Theme.of(context).colorScheme.surface,
        0.6,
      )!;
    }

    return Color.lerp(
      harmonized,
      Theme.of(context).colorScheme.onSurface,
      0.9,
    )!;
  }

  Color getSurfaceColor(BuildContext context) {
    return generateSurfaceContainer(
      color,
      Theme.brightnessOf(context) == Brightness.dark,
    ).harmonizeWith(context.col.primary);
  }

  Color getOnSurfaceColor(BuildContext context) {
    return generateOnSurfaceContainer(
      color,
      Theme.brightnessOf(context) == Brightness.dark,
    ).harmonizeWith(context.col.primary);
  }
}

Color generateSurfaceContainer(Color seedColor, bool isDark) {
  final hct = Hct.fromInt(seedColor.toARGB32());
  final surfaceContainerTone = isDark ? 13.0 : 90.0;
  final safeChroma = hct.chroma
      .clamp(0, 10)
      .toDouble(); // Lower chroma = less vibrance
  final adjusted = Hct.from(hct.hue, safeChroma, surfaceContainerTone);
  return Color(adjusted.toInt());
}

Color generateOnSurfaceContainer(Color seedColor, bool isDark) {
  final hct = Hct.fromInt(seedColor.toARGB32());
  final surfaceContainerTone = !isDark ? 45.0 : 80.0;
  final safeChroma = hct.chroma
      .clamp(0, 1000)
      .toDouble(); // Lower chroma = less vibrance
  final adjusted = Hct.from(hct.hue, safeChroma, surfaceContainerTone);
  return Color(adjusted.toInt());
}

Color generateOnColor(Color seedColor, bool isDark) {
  final hct = Hct.fromInt(seedColor.toARGB32());
  final surfaceContainerTone = isDark ? 13.0 : 98.0;
  final safeChroma = hct.chroma
      .clamp(0, 30)
      .toDouble(); // Lower chroma = less vibrance
  final adjusted = Hct.from(hct.hue, safeChroma, surfaceContainerTone);
  return Color(adjusted.toInt());
}
