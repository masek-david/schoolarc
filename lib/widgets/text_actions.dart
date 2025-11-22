import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class TextActions extends StatelessWidget {
  const TextActions({
    super.key,
    required this.text,
    this.greydOut = false,
    this.actions,
  });

  final String text;
  final bool greydOut;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final color = greydOut
        ? getSubtleTextColor(context)
        : Theme.of(context).colorScheme.onSurface;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        4,
        actions != null && actions!.isNotEmpty ? 0 : 8,
        0,
        actions != null && actions!.isNotEmpty ? 0 : 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: context.txt.bodyLarge!.copyWith(color: color),
            ),
          ),
          if (actions != null) ...actions!
        ],
      ),
    );
  }
}
