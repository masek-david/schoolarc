import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T> showDialogAdaptive<T>({
  required BuildContext context,
  Widget? title,
  Widget? content,
  List<Widget>? actions,
  bool? dismissible,
}) async {
  if (showCupertino(context)) {
    return await showCupertinoDialog(
      context: context,
      barrierDismissible: dismissible ?? false,
      builder: (context) {
        return _builder(context, title, content, actions);
      },
    );
  } else {
    return await showDialog(
      context: context,
      barrierDismissible: dismissible ?? true,
      builder: (context) {
        return _builder(context, title, content, actions);
      },
    );
  }
}

Widget _builder(
  BuildContext context,
  Widget? title,
  Widget? content,
  List<Widget>? actions,
) {
  return AlertDialog.adaptive(
    actions: actions,
    content: content,
    title: title,
  );
}

bool showCupertino(BuildContext context) {
  final platform = Theme.of(context).platform;

  return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}

Widget adaptiveDialogButton({
  required BuildContext context,
  required Widget child,
  bool isDefaultAction = false,
  bool isDestructiveAction = false,
  required void Function()? onPressed,
}) {
  if (showCupertino(context)) {
    return CupertinoDialogAction(
      isDestructiveAction: isDestructiveAction,
      isDefaultAction: isDefaultAction,
      onPressed: onPressed,
      child: child,
    );
  } else {
    if (isDefaultAction) {
      return FilledButton(onPressed: onPressed, child: child);
    }
    Color textColor = Theme.of(context).colorScheme.onSurface;
    if (isDestructiveAction) {
      textColor = Theme.of(context).colorScheme.error;
    }
    return TextButton(
      onPressed: onPressed,
      child: DefaultTextStyle(
        style: TextStyle(color: textColor),
        child: child,
      ),
    );
  }
}
