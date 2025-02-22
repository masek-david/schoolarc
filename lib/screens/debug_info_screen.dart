import 'dart:async';

import 'package:flutter/material.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/services/exams/exam_database.dart';
import 'package:school_manager/services/homeworks/hw_database.dart';
import 'package:school_manager/services/subjects/subject_database.dart';

class TestDatetime extends StatefulWidget {
  const TestDatetime({super.key});

  @override
  State<TestDatetime> createState() => _TestDatetimeState();
}

class _TestDatetimeState extends State<TestDatetime> {
  Timer? timer;
  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
        Duration(milliseconds: 100), (Timer t) => setState(() {}));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Text(DateTime.now().toString()),
    );
  }
}

class DbInfoScreen extends StatelessWidget {
  DbInfoScreen({super.key});

  final HomeworksDatabase homeworksDatabase = HomeworksDatabase();
  final ExamDatabase examDatabase = ExamDatabase();
  final subjectDatabase = SubjectDatabase();

  late final examDb = examDatabase.getDatabase();
  late final homeworkDb = homeworksDatabase.getDatabase();
  late final subjectsDb = subjectDatabase.getDatabase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: [
            TestDatetime(),
            const Text('SUBJECTS'),
            const Divider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: subjectsDb.entries.map((entry) {
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(entry.key.toString()),
                      ),
                      SizedBox(
                        width: 60,
                        child: Text(item.shortcut),
                      ),
                      Expanded(child: Text(item.name)),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 50),
            const Text('HOMEWORKS'),
            const Divider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: homeworkDb.entries.map((entry) {
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(entry.key.toString()),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          item.priority.toString(),
                          style: TextStyle(
                            color: TaskPriority(item.priority).color,
                          ),
                        ),
                      ),
                      Expanded(child: Text(item.text)),
                      if (item.isCompleted) const Text('(completed)'),
                      if (entry.value.isDeleted) Icon(Icons.delete),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 50),
            const Text('EXAMS'),
            const Divider(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: examDb.entries.map((entry) {
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 50,
                        child: Text(entry.key.toString()),
                      ),
                      SizedBox(
                        width: 30,
                        child: Text(
                          item.priority.toString(),
                          style: TextStyle(
                            color: TaskPriority(item.priority).color,
                          ),
                        ),
                      ),
                      Expanded(child: Text(item.text)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
