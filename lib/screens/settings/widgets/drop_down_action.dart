import 'package:flutter/material.dart';

class DropDownAction extends StatefulWidget {
  const DropDownAction({
    super.key,
    required this.items,
    required this.initialValue,
    required this.onChanged,
  });

  final List<DropdownMenuItem<Object>> items;
  final Object? initialValue;
  final void Function(Object? value) onChanged;

  @override
  State<DropDownAction> createState() => _DropDownActionState();
}

class _DropDownActionState extends State<DropDownAction> {
  late Object? _value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      value: _value,
      items: widget.items,
      onChanged: (value) {
        widget.onChanged(value);
        setState(() {
          _value = value;
        });
      },
    );
  }
}
