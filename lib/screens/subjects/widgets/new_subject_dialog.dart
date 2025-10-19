import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/buttons/cancel_save_button.dart';

class SubjectDialog extends ConsumerStatefulWidget {
  const SubjectDialog({
    super.key,
    required this.isEditing,
    required this.initial,
    this.usedTimes,
  });
  final int? usedTimes;

  /// If this is false, the user is creating new subject
  final bool isEditing;
  final Subject initial;

  @override
  ConsumerState<SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends ConsumerState<SubjectDialog> {
  late final TextEditingController nameController =
      TextEditingController(text: widget.initial.name);
  late final TextEditingController shortcutController =
      TextEditingController(text: widget.initial.shortcut);

  void onSave() {
    final edited = widget.initial.copyWith(
      name: nameController.text,
      shortcut: shortcutController.text,
      timestamp: DateTime.now(),
    );

    if (widget.isEditing) {
      ref.read(subjectsProvider.notifier).update(edited);
    } else {
      ref.read(subjectsProvider.notifier).create(edited.convert());
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    shortcutController.dispose();

    super.dispose();
  }

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
                widget.isEditing
                    ? context.loc.editSubject
                    : context.loc.addNewSubject,
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
            if (widget.usedTimes != null)
              Text(
                loc.subjectUsedTimes(widget.usedTimes!),
              ),
            CancelSaveButton(onSave: onSave)
          ],
        ),
      ),
    );
  }
}
