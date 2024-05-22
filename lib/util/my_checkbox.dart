import 'package:flutter/material.dart';
import 'package:school_manager/util/get_priority_color.dart';

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
    Color checkboxColor = getPriorityColor(priority: priority, context: context);

    return Checkbox(
      value: value,
      onChanged: onChanged,
      activeColor: checkboxColor,
      checkColor: Colors.white,
      side: BorderSide(color: checkboxColor, width: 2.7),
      shape: const CircleBorder(),
    );
  }
}
