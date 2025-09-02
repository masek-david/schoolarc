import 'package:flutter/material.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/screens/subjects/widgets/subject_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

Future<Subject?> showSelectSubject({
  required BuildContext context,
  required List<Subject> subjects,
  Function? delete,
}) {
  return showDialog<Subject?>(
    context: context,
    builder: (context) {
      return SelectSubjectDialog(
        subjects: subjects,
        delete: delete,
      );
    },
  );
}

class SelectSubjectDialog extends StatelessWidget {
  const SelectSubjectDialog({
    super.key,
    required this.subjects,
    this.delete,
    this.showAllSubjects = true,
  });

  final List<Subject> subjects;
  final Function? delete;
  final bool showAllSubjects;

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(12, 20, 12, 0),
      title: Text(loc.selectSubject),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.cancel),
        ),
        if (delete != null)
          TextButton(
            onPressed: () {
              delete!();
              Navigator.pop(context);
            },
            child: Text(loc.setToEmpty),
          ),
      ],
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Autocomplete<Subject>(
            onSelected: (option) {
              Navigator.pop(context, option);
            },
            fieldViewBuilder:
                (context, textEditingController, focusNode, onFieldSubmitted) {
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                autofocus: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (value) => onFieldSubmitted(),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  border: OutlineInputBorder(),
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
          if (showAllSubjects)
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
    );
  }
}
