import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('text of setting'),
        Switch(value: true, onChanged: (value) {})
      ],
    );
  }
}
