import 'package:flutter/material.dart';
import 'package:school_manager/services/exams/exam_database.dart';
import 'package:school_manager/services/homeworks/hw_database.dart';
import 'package:school_manager/services/subjects/subject_database.dart';

class DbInfoScreen extends StatelessWidget {
  DbInfoScreen({super.key});

  final HomeworksDatabase homeworksDatabase = HomeworksDatabase();
  final ExamDatabase examDatabase = ExamDatabase();
  final subjectDatabase = SubjectDatabase();

  late final examSequence = examDatabase.getSequence();
  late final homeworkSequence = homeworksDatabase.getSequence();
  late final examDb = examDatabase.getDatabase();
  late final homeworkDb = homeworksDatabase.getDatabase();
  late final subjectsDb = subjectDatabase.getDatabase();
  late final subjectsSequence = subjectDatabase.getSequence();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: [
            const Text('SUBJECTS'),
            const Divider(),
            Text(subjectsSequence.toString()),
            const Divider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: subjectsDb.entries.map((entry) {
                var item = entry.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${entry.key.toString()} '),
                    const SizedBox(width: 20),
                    Text(item.shortcut),
                    const SizedBox(width: 20),
                    Expanded(child: Text(item.name)),
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 50),
            const Text('HOMEWORKS'),
            const Divider(),
            Text(homeworkSequence.toString()),
            const Divider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: homeworkDb.entries.map((entry) {
                var item = entry.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.key.toString()),
                    const SizedBox(width: 20),
                    Text('pr.:  ${item.priority}'),
                    const SizedBox(width: 20),
                    Expanded(child: Text(item.text)),
                    if (item.completion) const Text('(completed)')
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 50),
            const Text('EXAMS'),
            const Divider(),
            Text(examSequence.toString()),
            const Divider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: examDb.entries.map((entry) {
                var item = entry.value;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key.toString()),
                    const SizedBox(width: 20),
                    Text('pr.:  ${item.priority}'),
                    const SizedBox(width: 20),
                    Expanded(child: Text(item.text)),
                    if (item.completion) const Text('(completed)')
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
