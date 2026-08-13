import 'package:flutter/material.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class CancelSaveButton extends StatelessWidget {
  const CancelSaveButton({
    super.key,
    required this.onSave,
    this.onCancel,
  });

  final Function() onSave;
  final Function()? onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          M3EFilledButton.tonalIcon(
            size: .md,
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              if (onCancel != null) {
                onCancel!();
              }
              Navigator.pop(context);
            },
            label: Text(context.loc.cancel),
          ),
          M3EFilledButton.icon(
            size: .md,
            onPressed: () {
              onSave();
              Navigator.maybePop(context);
            },
            icon: const Icon(Icons.check_rounded),
            label: Text(context.loc.save),
          ),
        ],
      ),
    );
  }
}
