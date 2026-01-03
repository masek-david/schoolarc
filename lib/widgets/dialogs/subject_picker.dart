import 'package:flutter/material.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/screens/subjects/widgets/new_subject_dialog.dart';
import 'package:schoolarc/screens/timetable/select_subject.dart';
import 'package:schoolarc/widgets/web_request_focus.dart';

class SubjectPicker extends StatelessWidget {
  const SubjectPicker({
    super.key,
    required this.subjects,
    required this.pickedSubjectId,
    required this.onSelected,
    this.chipKeys,
  });

  final List<Subject> subjects;
  final String? pickedSubjectId;
  final void Function(Subject? subject) onSelected;

  /// Map of Subject.id and GlobalKeys will be assigned to subject chips
  final Map<String, GlobalKey>? chipKeys;

  void searchSubject(BuildContext context) async {
    final newSubject = await showSelectSubject(
      context: context,
      subjects: subjects,
    );

    onSelected(newSubject);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        WebRequestFocusBuilder(
          builder: (showKeyboard) {
            return IconButton(
              onPressed: () {
                showKeyboard();
                searchSubject(context);
              },
              icon: const Icon(Icons.search),
            );
          },
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              // cant use .map(), i need the index
              children: [
                ...List.generate(
                  subjects.length,
                  (index) {
                    final subject = subjects[index];
                    
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        key: chipKeys?[subject.id],
                        selected: pickedSubjectId == subject.id,
                        label: Text(subject.name),
                        onSelected: (value) {
                          if (!value) {
                            onSelected(null);
                          } else {
                            onSelected(subject);
                          }
                        },
                      ),
                    );
                  },
                ),
                FilledButton.tonalIcon(
                  icon: const Icon(Icons.add_rounded),
                  onPressed: () => addNewSubject(context),
                  label: const Text('Create a new subject'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
