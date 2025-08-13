import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class JoinGroupDialog extends StatefulWidget {
  const JoinGroupDialog({
    super.key,
    required this.onConfirm,
    required this.title,
    required this.confirmText,
  });

  final void Function(String) onConfirm;
  final String title;
  final String confirmText;

  @override
  State<JoinGroupDialog> createState() => _JoinGroupDialogState();
}

class _JoinGroupDialogState extends State<JoinGroupDialog> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        autofocus: true,
        controller: controller,
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.all(15),
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          child: Text(context.loc.close),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirm(controller.text);
          },
          child: Text(widget.confirmText),
        ),
      ],
    );
  }
}
