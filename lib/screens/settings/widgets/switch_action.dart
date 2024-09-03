import 'package:flutter/material.dart';

class SwitchAction extends StatefulWidget {
  const SwitchAction({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  final bool initialValue;
  final void Function(bool value) onChanged;

  @override
  State<SwitchAction> createState() => _SwitchActionState();
}

class _SwitchActionState extends State<SwitchAction> {
  late bool switchValue = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: switchValue,
      onChanged: (value) => setState(() {
        widget.onChanged(value);
        switchValue = value;
      }),
    );
  }
}
