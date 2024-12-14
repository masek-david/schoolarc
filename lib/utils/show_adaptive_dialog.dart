import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<T> showDialogAdaptive<T>({
  required BuildContext context,
  Widget? title,
  Widget? content,
  List<Widget>? actions,
}) async {
  if (showCupertino(context)) {
    return await showCupertinoDialog(
      context: context,
      builder: (context) {
        return _builder(context, title, content, actions);
      },
    );
  } else {
    return await showDialog(
      context: context,
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
  required void Function()? onPressed,
}) {
  if (showCupertino(context)) {
    return CupertinoButton(onPressed: onPressed, child: child);
  } else {
    return TextButton(onPressed: onPressed, child: child);
  }
}
