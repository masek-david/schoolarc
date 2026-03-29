import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class TextActions extends StatelessWidget {
  const TextActions({
    super.key,
    required this.text,
    this.greydOut = false,
    this.actions = const [],
    this.color,
    this.padding,
  });

  final String text;
  final bool greydOut;
  final List<Widget> actions;
  final Color? color;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final textColor = greydOut ? getSubtleTextColor(context) : color;

    return Padding(
      padding: padding ?? EdgeInsets.fromLTRB(4, actions.isEmpty ? 8 : 0, 0, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: context.txt.titleMedium!.copyWith(
                color: textColor,
              ),
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}
