import 'package:flutter/material.dart';

class DropDownAction<T> extends StatelessWidget {
  const DropDownAction({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  final List<DropdownMenuItem<T>> items;
  final T? value;
  final void Function(T? value) onChanged;

  @override
  Widget build(BuildContext context) {
    assert(
      value == null || items.any((e) => e.value == value),
      'items doesn\'t include this value',
    );

    return DropdownButton<T>(
      value: value,
      items: items,
      onChanged: onChanged,
    );
  }
}
