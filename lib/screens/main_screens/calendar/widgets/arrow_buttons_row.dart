import 'package:flutter/material.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

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
    return M3EFilledIconButton.tonal(
      onPressed: onPressed,
      decoration: M3EButtonDecoration(
        backgroundColor: WidgetStatePropertyAll(
          context.col.surfaceContainerHighest.withAlpha(120),
        ),
      ),
      icon: Icon(
        left
            ? Icons.keyboard_arrow_left_rounded
            : Icons.keyboard_arrow_right_rounded,
      ),
    );
  }
}
