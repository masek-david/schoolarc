import 'package:flutter/material.dart';

class DropDownAction extends StatelessWidget {
  const DropDownAction({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final List<DropdownMenuItem<Object>> items;
  final Object? value;
  final void Function(Object? value) onChanged;

  @override
  Widget build(BuildContext context) {
    assert(items.map((e) => e.value).contains(value), 'items doesn\'t include this value');

    return DropdownButton(
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
