import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

void showButtonDialog(
  BuildContext context, {
  required String title,
  required IconData icon,
  required List<Widget> buttons,
}) {
  showDialog(
    context: context,
    builder: (context) {
      return ButtonDialog(
        buttons: buttons,
        icon: icon,
        title: title,
      );
    },
  );
}

class ButtonDialog extends StatelessWidget {
  const ButtonDialog({
    super.key,
    required this.buttons,
    required this.icon,
    required this.title,
  });

  final List<Widget> buttons;
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsetsGeometry.all(20),
        child: Column(
          mainAxisSize: .min,
          spacing: 4,
          crossAxisAlignment: .start,
          children: [
            Center(child: Icon(icon)),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  title,
                  style: context.txt.headlineSmall,
                ),
              ),
            ),
            ...buttons,
          ],
        ),
      ),
    );
  }
}

class ButtonDialogButton extends StatelessWidget {
  const ButtonDialogButton({
    super.key,
    this.isFirst = false,
    this.isLast = false,
    required this.text,
    this.description,
    required this.onTap,
  });

  final bool isFirst;
  final bool isLast;
  final String text;
  final String? description;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        clipBehavior: .antiAlias,
        color: context.col.primaryContainer,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isFirst ? 16 : 4),
          bottom: Radius.circular(isLast ? 16 : 4),
        ),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                text,
                style: context.txt.labelLarge!.copyWith(
                  color: context.col.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
