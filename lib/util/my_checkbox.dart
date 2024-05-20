import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

class MyCheckbox extends StatelessWidget {
  const MyCheckbox({
    required this.value,
    required this.priority,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final int priority;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    Color checkboxColor;
    switch (priority) {
      case 3:
        checkboxColor =
            Colors.red.harmonizeWith(Theme.of(context).primaryColor);
      case 2:
        checkboxColor =
            Colors.orange.harmonizeWith(Theme.of(context).primaryColor);
      case 1:
        checkboxColor =
            Colors.green.harmonizeWith(Theme.of(context).primaryColor);
      default:
        checkboxColor =
            Colors.blue.harmonizeWith(Theme.of(context).primaryColor);
    }

    return Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: checkboxColor,
      side: BorderSide(color: checkboxColor, width: 2.7),
      shape: const CircleBorder(),
    );
  }
}
