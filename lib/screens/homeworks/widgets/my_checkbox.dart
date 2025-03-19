import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/models/priority_model.dart';

class MyCheckbox extends StatelessWidget {
  const MyCheckbox({
    required this.value,
    required this.priority,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final TaskPriority priority;
  final void Function(bool)? onChanged;

  // late bool checboxValue = widget.value;
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.3,
      child: Checkbox( 
        value: value,
        activeColor: priority.getColor(context),
        checkColor: Colors.white,
        side: BorderSide(color: priority.getColor(context), width: 2.7),
        shape: const CircleBorder(),
        onChanged: (value) {
          if (onChanged != null) {
            HapticFeedback.mediumImpact();
            onChanged!(value!);
            // setState(() {
            //   checboxValue = value;
            // });
          }
        },
      ),
    );
  }
}
