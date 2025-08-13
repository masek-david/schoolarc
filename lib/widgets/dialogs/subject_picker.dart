import 'package:flutter/material.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/screens/timetable/select_subject.dart';

class SubjectPicker extends StatelessWidget {
  const SubjectPicker({
    super.key,
    required this.subjects,
    required this.pickedSubjectId,
    required this.onSelected,
    this.keys,
  });

  final List<Subject> subjects;
  final String? pickedSubjectId;
  final void Function(Subject? subject) onSelected;
    /// these will be assigned to every subject button
  final List<GlobalKey>? keys;

  void searchSubject(BuildContext context) async {
    final newSubject = await showDialog(
      context: context,
      builder: (context) => SelectSubjectDialog(
        subjects: subjects,
        showAllSubjects: false,
      ),
    );

    onSelected(newSubject);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => searchSubject(context),
          icon: const Icon(Icons.search),
        ),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              // cant use .map(), i need the index
              children: List.generate(subjects.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    key: keys?[index],
                    selected: pickedSubjectId == subjects[index].id,
                    label: Text(subjects[index].name),
                    onSelected: (value) {
                      if (!value) {
                        onSelected(null);
                      } else {
                        onSelected(subjects[index]);
                      }
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ],
    );
  }
}
