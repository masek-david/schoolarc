import 'package:flutter/material.dart';

class ArrowButtonsRow extends StatelessWidget {
  const ArrowButtonsRow({
    super.key,
    required this.onPressedLeft,
    required this.onPressedRight,
  });

  final void Function() onPressedLeft;
  final void Function() onPressedRight;

  @override
  Widget build(BuildContext context) {
    final color =
        Theme.of(context).colorScheme.surfaceContainerHigh.withAlpha(120);
    final padding = const EdgeInsets.all(6);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPressedLeft,
          icon: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: color,
            ),
            child: const Icon(Icons.keyboard_arrow_left),
          ),
        ),
        IconButton(
          onPressed: onPressedRight,
          icon: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: color,
            ),
            child: const Icon(Icons.keyboard_arrow_right),
          ),
        ),
      ],
    );
  }
}
