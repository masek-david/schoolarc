import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ArrowButton(onPressed: onPressedLeft, left: true),
        ArrowButton(onPressed: onPressedRight),
      ],
    );
  }
}

class ArrowButton extends StatelessWidget {
  const ArrowButton({super.key, required this.onPressed, this.left = false});

  final void Function() onPressed;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return IconButtonM3E.tonal(
      onPressed: onPressed,
      // TODO error
      // backgroundColor: context.col.surfaceContainerHighest.withAlpha(120),
      icon: Icon(
        left
            ? Icons.keyboard_arrow_left_rounded
            : Icons.keyboard_arrow_right_rounded,
      ),
    );
  }
}
