import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/raw_button_m3e.dart';
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
    return RawButtonM3E(
      iconSpacing: 12,
      outlineWidth: null,
      outlineColor: null,
      alignment: .start,
      icon: icon,
      onPressed: onTap,
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: WidgetStatePropertyAll(context.col.onSurfaceVariant),
      elevation: const WidgetStatePropertyAll(0),
      width: double.infinity,
      height: 56,
      iconSize: 24,
      radius: WidgetStatePropertyAll(.circular(28)),
      padding: 16,
      fontSize: 14,
      child: Row(
        children: [
          Expanded(child: Text(text)),
          if (showBadge)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
                color: Colors.red,
              ),
              height: 8,
              width: 8,
            ),
        ],
      ),
    );
  }
}
