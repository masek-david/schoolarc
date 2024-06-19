import 'package:flutter/material.dart';
import 'package:school_manager/util/cancel_save_button.dart';

class NewSubjectDialog extends StatelessWidget {
  const NewSubjectDialog({
    super.key,
    required this.nameController,
    required this.shortcutController,
    required this.onSave,
  });

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
            const Padding(
              padding: EdgeInsets.only(top: 8, bottom: 16),
              child: Text(
                'Add new subject',
                style: TextStyle(fontSize: 18),
              ),
            ),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(),
                labelText: 'Name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: shortcutController,
              maxLength: 5,
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
