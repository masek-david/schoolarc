import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/color_extension.dart';

/// used in calendar views for dividing exams and homeworks
class TextSeparator extends StatelessWidget {
  const TextSeparator({
    super.key,
    this.text = '',
    this.greydOut = false,
    this.actions,
  });

  final String text;
  final bool greydOut;
  final List<Widget>? actions;

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
      padding: EdgeInsets.symmetric(
          vertical: actions != null ? 0 : 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 16, color: color),
          ),
          if (actions != null)
            Row(
              children: actions!,
            ),
        ],
      ),
    );
  }
}
