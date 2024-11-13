import 'package:flutter/material.dart';
import 'package:school_manager/extensions/color_extension.dart';

/// used in calendar views for dividing exams and homeworks
class TextSeparator extends StatelessWidget {
  const TextSeparator({
    super.key,
    this.text = '',
    this.greydOut = false,
    this.action,
  });

  final String text;
  final bool greydOut;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).colorScheme.onSurface;

    if (greydOut) {
      color = color.dynamicLighten(
        makeItLighter: Theme.of(context).brightness != Brightness.dark,
        amount: 0.4,
      );
    }

    return Padding(
      // padding: const EdgeInsets.only(left: 10, right: 10, top: 20, bottom: 0),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 16, color: color),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}
