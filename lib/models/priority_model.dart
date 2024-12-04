import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

class TaskPriority {
  final int index;
  late String name;
  late Color color;
  late String htmlIcon;

  TaskPriority(this.index) {
    switch (index) {
      case 3:
        color = Colors.red;
        htmlIcon = '&#128308;';
        name = 'High';
      case 2:
        color = Colors.orange;
        htmlIcon = '&#128992;';
        name = 'Medium';
      case 1:
        color = Colors.green;
        htmlIcon = '&#128994;';
        name = 'Low';
      default:
        color = Colors.blue;
        htmlIcon = '&#128309;';
        name = 'No priority';
    }
  }

  Color getColor(BuildContext context) {
    return color.harmonizeWith(Theme.of(context).colorScheme.primary);
  }

  Color getContainerColor(BuildContext context) {
    final harmonized =
        color.harmonizeWith(Theme.of(context).colorScheme.primary);

    return Color.lerp(harmonized, Theme.of(context).colorScheme.surface, 0.3)!;
  }

  Color getOnContainerColor(BuildContext context) {
    final harmonized =
        color.harmonizeWith(Theme.of(context).colorScheme.primary);

    return Color.lerp(
        harmonized, Theme.of(context).colorScheme.onSurface, 0.9)!;
  }
}
