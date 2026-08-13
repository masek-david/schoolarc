import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class PriorityIcon extends StatelessWidget {
  const PriorityIcon({super.key, required this.priority, this.color});

  final int priority;
  final Color? color;

  Widget buildDot(BuildContext context, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: .circular(100),
        color: color ?? context.col.onSurface,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final count = priority + 1;

    final padding = count == 4 ? 1.2 : 2.0;
    final size = count == 1 ? 6.0 : 4.0;

    return Column(
      children: [
        if (count > 2)
          Row(
            children: [
              buildDot(context, size),
              if (count > 3) SizedBox(width: padding),
              if (count > 3) buildDot(context, size),
            ],
          ),
        if (count == 3) const SizedBox(height: 1.41),// sqare root of 2
        if (count == 4) SizedBox(height: padding),
        Row(
          children: [
            buildDot(context, size),
            if (count > 1) SizedBox(width: padding),
            if (count > 1) buildDot(context, size),
          ],
        ),
      ],
    );
  }
}
