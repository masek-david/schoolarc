import 'package:flutter/material.dart';
import 'package:school_manager/data/exams_data/exam_database.dart';
import 'package:school_manager/data/homeworks_data/hw_database.dart';

class DbInfoScreen extends StatelessWidget {
  DbInfoScreen({super.key});

  final HomeworksDatabase homeworksDatabase = HomeworksDatabase();
  final ExamDatabase examDatabase = ExamDatabase();

  late final examSequence = examDatabase.getSequence();
  late final homeworkSequence = homeworksDatabase.getSequence();
  late final examDb = examDatabase.getDatabase();
  late final homeworkDb = homeworksDatabase.getDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: [
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
                  children: [
                    Text('${entry.key.toString()},     pr.:  ${item.priority}'),
                    Text(item.text),
                    if(item.completion) const Text('(completed)')
                  ],
                );
              }).toList(),
            ),
            const SizedBox(height: 50,),
            const Text('EXAMS') ,
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
                    Text('${entry.key.toString()},     pr.:  ${item.priority}'),
                    Text(item.text),
                    if(item.completion) const Text('(completed)')
                  ],
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
