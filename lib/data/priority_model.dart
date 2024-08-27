import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

class Priority {
  final int index;
  String name = 'not_known';
  Color color = Colors.white;

  Priority(this.index, context) {
    switch (index) {
      case 3:
        color = Colors.red.harmonizeWith(Theme.of(context).primaryColor);
        name = 'High';
      case 2:
        color = Colors.orange.harmonizeWith(Theme.of(context).primaryColor);
        name = 'Medium';
      case 1:
        color = Colors.green.harmonizeWith(Theme.of(context).primaryColor);
        name = 'Low';
      default:
        color = Colors.blue.harmonizeWith(Theme.of(context).primaryColor);
        name = 'No priority';
    }
  }
}
