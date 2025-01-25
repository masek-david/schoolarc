import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/screens/exams/widgets/exam_tile.dart';
import 'package:school_manager/tasks_app.dart';

class WelcomeScreenExams extends StatefulWidget {
  const WelcomeScreenExams({super.key});

  @override
  State<WelcomeScreenExams> createState() => _WelcomeScreenExamsState();
}

class _WelcomeScreenExamsState extends State<WelcomeScreenExams>
    with TickerProviderStateMixin {
  late final homeworks = List.generate(3, (index) {
    String text = '';

    switch (index) {
      case 0:
        text = 'Slide and tap to delete';
      case 1:
        text = 'Tap to edit';
      case 2:
        text = 'Hold to reorder';
    }

    return ExamDTO(
      subject: SubjectDTO(
        name: 'Subject',
        shortcut: 'Hw',
        dbIndex: 0,
        isDeleted: false,
        bakaId: null,
        fireId: null,
        timestamp: Timestamp.now(),
        order: 0,
      ),
      text: text,
      description: null,
      deadline: DateTime.now().toUtc().add(const Duration(days: 1)).toLocal(),
      completion: false,
      priority: TaskPriority(index),
      dbIndex: index,
      fireId: '',
      timestamp: Timestamp.now(),
      isDeleted: false,
    );
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            'Exams work in a similar way:',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          const Text(
            'Exams are automatically completed after their date',
          ),
          const SizedBox(height: 50),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                showMessage(context, 'This way you reorder');
                setState(() {
                  final removedHw = homeworks.removeAt(oldIndex);
                  homeworks.insert(
                      newIndex >= oldIndex ? newIndex - 1 : newIndex,
                      removedHw);
                });
              },
              children: [
                ...homeworks.map(
                  (e) {
                    return Padding(
                      key: Key('welcome_hw_${e.dbIndex}'),
                      padding: const EdgeInsets.all(8.0),
                      child: ExamTile(
                        exam: e,
                        onDelete: (context) {
                          showMessage(context, 'Exam would be deleted');
                        },
                        onEdit: () {
                          showMessage(context, 'Now you could edit');
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    ));
  }
}
