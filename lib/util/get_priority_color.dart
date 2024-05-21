import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

Color getPriorityColor({required int priority, required dynamic context}) {
  Color color;
  
  switch (priority) {
      case 3:
        color =
            Colors.red.harmonizeWith(Theme.of(context).primaryColor);
      case 2:
        color =
            Colors.orange.harmonizeWith(Theme.of(context).primaryColor);
      case 1:
        color =
            Colors.green.harmonizeWith(Theme.of(context).primaryColor);
      default:
        color =
            Colors.blue.harmonizeWith(Theme.of(context).primaryColor);
    }

  return color;
}