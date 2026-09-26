import 'package:flutter/material.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/screens/subjects/widgets/subject_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';

Future<Subject?> showSelectSubject({
  required BuildContext context,
  required List<Subject> subjects,
}) {
  return showDialog<Subject?>(
    context: context,
    builder: (context) {
      return SelectSubjectDialog(
        subjects: subjects,
      );
    },
  );
}

class SelectSubjectDialog extends StatelessWidget {
  const SelectSubjectDialog({
    super.key,
    required this.subjects,
  });

  final List<Subject> subjects;

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
      title: Text(loc.selectSubject),
      actions: [
        DialogActionButton(
          onPressed: () => Navigator.pop(context),
          text: loc.cancel,
        ),
      ],
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Autocomplete<Subject>(
              onSelected: (option) {
                Navigator.pop(context, option);
              },
              fieldViewBuilder:
                  (
                    context,
                    textEditingController,
                    focusNode,
                    onFieldSubmitted,
                  ) {
                    return TextField(
                      key: const Key('search'),
                      controller: textEditingController,
                      focusNode: focusNode,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) => onFieldSubmitted(),
                      decoration: InputDecoration(
                        hintText: loc.searchForSubject,
                      ),
                    );
                  },
              displayStringForOption: (option) => option.name,
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<Subject>.empty();
                }
                return subjects.where(
                  (subject) => subject.containsText(textEditingValue.text),
                );
              },
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: SubjectTile(
                        subject: subject,
                        onTap: () => Navigator.pop(context, subject),
                        onDelete: null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
