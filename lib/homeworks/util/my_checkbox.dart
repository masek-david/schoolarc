import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/util/priority_model.dart';

class MyCheckbox extends StatelessWidget {
  const MyCheckbox({
    required this.value,
    required this.priority,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final Priority priority;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
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
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    onChanged(value);
                  },
                ),
              ),
            );
          }
        },
        activeColor: priority.color,
        checkColor: Colors.white,
        side: BorderSide(color: priority.color, width: 2.7),
        shape: const CircleBorder(),
      ),
    );
  }
}
