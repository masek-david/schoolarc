import 'package:flutter/material.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/m3e/error_button_styles.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

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
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    if (isDefaultAction) {
      return M3EFilledButton(
        onPressed: onPressed,
        decoration: isDestructiveAction
            ? ErrorButtonStyle.filled(context.col)
            : null,
        child: Text(text),
      );
    }
    return M3ETextButton(
      onPressed: onPressed,
      decoration: isDestructiveAction
          ? ErrorButtonStyle.text(context.col)
          : null,
      child: Text(text),
    );
  }
}
