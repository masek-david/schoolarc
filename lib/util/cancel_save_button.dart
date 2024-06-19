import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CancelSaveButton extends StatelessWidget {
  const CancelSaveButton({super.key, required this.onSave, this.onCancel});

  final Function onSave;
  final Function? onCancel;

  @override
  Widget build(BuildContext context) {
    // onCancel ??=

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton(
          onPressed: () {
            if (onCancel != null) {
              onCancel!();
            }
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            onSave();
            Navigator.pop(context);
          },
          child: const Text('Save'),
        )
      ],
    );
  }
}
