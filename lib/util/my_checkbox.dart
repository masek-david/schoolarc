import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    Color checkboxColor =
        getPriorityColor(priority: priority, context: context);

    return Transform.scale(
      scale: 1.2,
      child: Checkbox(
        value: value,
        onChanged: (value) {
          onChanged(value);
          HapticFeedback.mediumImpact();
          if (value == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: const Text('Homework marked as completed'),
                  duration: const Duration(milliseconds: 2000),
                  action: SnackBarAction(label: 'Undo', onPressed: () {
                    onChanged(value);
                  }, ),
                  ),
            );
          }
        },
        activeColor: checkboxColor,
        checkColor: Colors.white,
        side: BorderSide(color: checkboxColor, width: 2.7),
        shape: const CircleBorder(),
      ),
    );
  }
}
