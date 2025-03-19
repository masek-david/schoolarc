import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

class TaskPriority {
  late final int index;
  late String name;
  late Color color;
  late String htmlIcon;

  TaskPriority(int index) {
    switch (index) {
      case 3:
        color = Colors.red;
        htmlIcon = '\uD83D\uDD34';
        name = 'High';
        this.index = 3;
      case 2:
        color = Colors.orange;
        htmlIcon = '\uD83D\uDFE0';
        name = 'Medium';
        this.index = 2;
      case 1:
        color = Colors.green;
        htmlIcon = '\uD83D\uDFE2';
        name = 'Low';
        this.index = 1;
      default:
        color = Colors.blue;
        htmlIcon = '\uD83D\uDD35';
        name = 'No priority';
        this.index = 0;
    }
  }

  Color getColor(BuildContext context) {
    return color.harmonizeWith(Theme.of(context).colorScheme.primary);
  }

  Color getContainerColor(BuildContext context, {bool subtle = false}) {
    final harmonized =
        color.harmonizeWith(Theme.of(context).colorScheme.primary);

    return Color.lerp(harmonized, Theme.of(context).colorScheme.surface, subtle ? 0.85 : 0.3)!;
  }

  Color getOnContainerColor(BuildContext context) {
    final harmonized =
        color.harmonizeWith(Theme.of(context).colorScheme.primary);

    return Color.lerp(
        harmonized, Theme.of(context).colorScheme.onSurface, 0.9)!;
  }
}
