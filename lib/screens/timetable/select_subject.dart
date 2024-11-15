import 'package:flutter/material.dart';
import 'package:school_manager/data/subjects_data/subject_dto_model.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';

Future<SubjectDTO?> showSelectSubject({
  required BuildContext context,
  required List<SubjectDTO> subjects,
  required Function delete,
}) {
  return showDialog<SubjectDTO?>(
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
    required this.delete,
  });

  final List<SubjectDTO> subjects;
  final Function delete;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Padding(
      padding: const EdgeInsets.only(
        top: 16,
        left: 8,
        right: 8,
        bottom: 6,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Select a subject: ',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Autocomplete(
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
            displayStringForOption: (option) {
              return option.name;
            },
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<SubjectDTO>.empty();
              }
              return subjects.where(
                (subject) {
                  return subject.containsText(textEditingValue.text);
                },
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: subjects.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(4),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            delete();
                            Navigator.pop(context);
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 8),
                            child: Text(
                              'Clear',
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final subject = subjects[index - 1];

                return Padding(
                  padding: const EdgeInsets.all(4),
                  child: SubjectTile(
                    subject: subject,
                    onTap: () {
                      Navigator.pop(context, subject);
                    },
                    onDelete: null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ));
  }
}
