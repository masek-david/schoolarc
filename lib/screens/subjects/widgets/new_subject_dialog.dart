import 'package:flutter/material.dart';
import 'package:school_manager/widgets/cancel_save_button.dart';

class SubjectDialog extends StatelessWidget {
  const SubjectDialog({
    super.key,
    required this.nameController,
    required this.shortcutController,
    required this.onSave,
    required this.text,
  });

  final String text;
  final TextEditingController nameController;
  final TextEditingController shortcutController;
  final void Function() onSave;

  @override
  Widget build(BuildContext context) {
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
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(),
                labelText: 'Name',
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
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(),
                labelText: 'Shortcut (max 5 characters)',
              ),
            ),
            CancelSaveButton(onSave: onSave)
          ],
        ),
      ),
    );
  }
}
