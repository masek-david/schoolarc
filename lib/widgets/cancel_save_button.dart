import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CancelSaveButton extends StatelessWidget {
  const CancelSaveButton({
    super.key,
    required this.onSave,
    this.onCancel,
    this.middle,
  });

  final Function() onSave;
  final Function()? onCancel;
  final Widget? middle;

  @override
  Widget build(BuildContext context) {
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
        if(middle != null) middle!,
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
