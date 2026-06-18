import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/button_m3e.dart';

Future<T> showMyDialog<T>({
  required BuildContext context,
  IconData? icon,
  String? title,
  String? text,
  Widget? content,
  List<Widget>? actions,
  bool dismissible = true,
}) async {
  return await showDialog(
    context: context,
    barrierDismissible: dismissible,
    builder: (context) {
      return AlertDialog(
        title: title != null ? Text(title) : null,
        content: content ?? (text != null ? Text(text) : null),
        icon: icon != null ? Icon(icon) : null,
        actions: actions,
      );
    },
  );
}

class DialogActionButton extends StatelessWidget {
  const DialogActionButton({
    super.key,
    required this.text,
    this.isDefaultAction = false,
    this.isDestructiveAction = false,
    required this.onPressed,
  });

  final String text;
  final bool isDefaultAction;
  final bool isDestructiveAction;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    if (isDefaultAction) {
      return ButtonM3E.filled(
        onPressed: onPressed,
        error: isDestructiveAction,
        child: Text(text),
      );
    }
    return ButtonM3E.text(
      onPressed: onPressed,
      error: isDestructiveAction,
      child: Text(text),
    );
  }
}
