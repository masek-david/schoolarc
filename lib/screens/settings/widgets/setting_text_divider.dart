import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class SettingTextDivider extends StatelessWidget {
  const SettingTextDivider({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 16, bottom: 4),
      child: Text(text, style: context.txt.titleMedium),
    );
  }
}
