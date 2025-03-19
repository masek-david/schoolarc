import 'dart:async';

import 'package:flutter/material.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/tasks_app.dart';

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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(DateTime.now().toString()),
      ),
    );
  }
}

class DbInfoScreen extends StatelessWidget {
  DbInfoScreen({super.key});

  late final exams = examsDb.getDatabase();
  late final hws = homeworksDb.getDatabase();
  late final subjects = subjectsDb.getDatabase();

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
              children: subjects.entries.map((entry) {
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
                      if (item.isDeleted) Icon(Icons.delete)
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
              children: hws.entries.map((entry) {
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
                      if (item.isCompleted) Icon(Icons.check),
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
              children: exams.entries.map((entry) {
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
                      if (entry.value.isDeleted) Icon(Icons.delete),
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
