import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/button_m3e.dart';
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
          ButtonM3E.tonal(
            size: .medium,
            icon: const Icon(Icons.close_rounded),
            onPressed: () {
              if (onCancel != null) {
                onCancel!();
              }
              Navigator.pop(context);
            },
            child: Text(context.loc.cancel),
          ),
          ButtonM3E.filled(
            size: .medium,
            onPressed: () {
              onSave();
              Navigator.maybePop(context);
            },
            icon: const Icon(Icons.check_rounded),
            child: Text(context.loc.save),
          ),
        ],
      ),
    );
  }
}
