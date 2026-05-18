import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/raw_button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
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
    final size = ButtonSize.medium;

    return RawButtonM3E(
      alignment: .start,
      icon: icon,
      onPressed: onTap,
      backgroundColor: Colors.transparent,
      foregroundColor: context.col.primary,
      elevation: 0,
      hoverElevation: 0,
      width: double.infinity,
      height: size.height,
      iconSize: 20,
      iconPadding: 12,
      radius: size.height / 2,
      pressedRadius: size.pressedRadius,
      padding: size.padding,
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
