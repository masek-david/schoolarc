import 'package:flutter/material.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class MyDrawerButton extends StatelessWidget {
  const MyDrawerButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  final String text;
  final Icon icon;
  final void Function() onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    final col = context.col;

    return TextButton(
      onPressed: onTap,
      style: ButtonStyle(
        splashFactory: NewInkSparkle.splashFactory,
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        foregroundColor: WidgetStatePropertyAll(
          col.onSurfaceVariant,
        ),
        iconSize: const WidgetStatePropertyAll(24),
        iconColor: WidgetStatePropertyAll(col.onSurfaceVariant),
        fixedSize: const WidgetStatePropertyAll(Size(double.infinity, 56)),
        overlayColor: WidgetStatePropertyAll(
          col.onSecondaryContainer.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          icon,
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
          if (showBadge) const SizedBox(width: 12),
          if (showBadge)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
                color: Colors.red,
              ),
              height: 8,
              width: 8,
            ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}
