import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

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
          child: Text(context.loc.cancel),
        ),
        ?middle,
        FilledButton(
          onPressed: () {
            onSave();
            Navigator.maybePop(context);
          },
          child: Text(context.loc.save),
        )
      ],
    );
  }
}
