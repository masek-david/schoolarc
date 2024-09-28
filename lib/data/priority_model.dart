import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

class Priority {
  final int index;
  late String name;
  late Color color;
  late String htmlIcon;

  Priority(this.index, BuildContext? context) {
    Color appColor = Colors.white;
    if (context != null) {
      appColor = Theme.of(context).primaryColor;
    }

    switch (index) {
      case 3:
        color = Colors.red.harmonizeWith(appColor);
        htmlIcon = '&#128308;';
        name = 'High';
      case 2:
        color = Colors.orange.harmonizeWith(appColor);
        htmlIcon = '&#128992;';
        name = 'Medium';
      case 1:
        color = Colors.green.harmonizeWith(appColor);
        htmlIcon = '&#128994;';
        name = 'Low';
      default:
        color = Colors.blue.harmonizeWith(appColor);
        htmlIcon = '&#128309;';
        name = 'No priority';
    }
  }
}
