import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/data/priority_model.dart';

class MyCheckbox extends StatefulWidget {
  const MyCheckbox({
    required this.value,
    required this.priority,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final Priority priority;
  final void Function(bool) onChanged;

  @override
  State<MyCheckbox> createState() => _MyCheckboxState();
}

class _MyCheckboxState extends State<MyCheckbox> {
  late bool checboxValue = widget.value;
  
  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 1.2,
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
          // if (value == true) {
          //   ScaffoldMessenger.of(context).clearSnackBars();
          //   ScaffoldMessenger.of(context).showSnackBar(
          //     SnackBar(
          //       content: const Text('Homework marked as completed'),
          //       duration: const Duration(milliseconds: 2000),
          //       action: SnackBarAction(
          //         label: 'Undo',
          //         onPressed: () {
          //           widget.onChanged(false);
          //         },
          //       ),
          //     ),
          //   );
          // }
        },
      ),
    );
  }
}
