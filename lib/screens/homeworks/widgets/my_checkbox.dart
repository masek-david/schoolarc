import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/models/priority_model.dart';

class MyCheckbox extends StatefulWidget {
  const MyCheckbox({
    required this.value,
    required this.priority,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final TaskPriority priority;
  final void Function(bool) onChanged;

  @override
  State<MyCheckbox> createState() => _MyCheckboxState();
}

class _MyCheckboxState extends State<MyCheckbox> {
  late bool checboxValue = widget.value;
  
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.3,
      child: Checkbox(
        value: checboxValue,
        activeColor: widget.priority.color,
        checkColor: Colors.white,
        side: BorderSide(color: widget.priority.color, width: 2.7),
        shape: const CircleBorder(),
        onChanged: (value) {
          HapticFeedback.mediumImpact();
          widget.onChanged(value!);
          setState(() {
            checboxValue = value;
          });
        },
      ),
    );
  }
}
