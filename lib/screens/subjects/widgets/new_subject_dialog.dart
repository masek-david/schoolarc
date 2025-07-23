import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/cancel_save_button.dart';

class SubjectDialog extends StatelessWidget {
  const SubjectDialog({
    super.key,
    required this.nameController,
    required this.shortcutController,
    required this.onSave,
    required this.text,
    this.usedTimes,
  });

  final String text;
  final TextEditingController nameController;
  final TextEditingController shortcutController;
  final int? usedTimes;
  final void Function() onSave;

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Text(
                text,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            TextField(
              controller: nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(15),
                border: const OutlineInputBorder(),
                labelText: loc.name,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: shortcutController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 5,
              onSubmitted: (text) {
                onSave();
                Navigator.pop(context);
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(15),
                border: const OutlineInputBorder(),
                labelText: loc.shortcutMax5Chars,
              ),
            ),
            if (usedTimes != null)
              Text(
                loc.subjectUsedTimes(usedTimes!),
              ),
            CancelSaveButton(onSave: onSave)
          ],
        ),
      ),
    );
  }
}
