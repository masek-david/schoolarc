// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/exam_database.dart';
import 'package:schoolarc/database/hw_database.dart';
import 'package:schoolarc/database/subject_database.dart';
import 'package:schoolarc/models/homeworks/homework_id_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/services/secure_storage.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/show_adaptive_dialog.dart';

class DbInfoScreen extends ConsumerWidget {
  DbInfoScreen({super.key});

  late final exams = examsDb.getDatabase();
  late final hws = homeworksDb.getDatabase();
  late final subjects = subjectsDb.getDatabase();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: [
            if (kDebugMode)
              FloatingActionButton.extended(
                onPressed: () {
                  HomeworksDatabase().deleteAllFromDisk();
                  SubjectDatabase().deleteAllFromDisk();
                  ExamDatabase().deleteAllFromDisk();
                },
                label: const Text('delete from disk'),
                icon: const Icon(Icons.bug_report),
              ),
            const Divider(),
            const Text('SECURE STORAGE'),
            FilledButton(
              onPressed: () async {
                final text =
                    await secureStorage.read(SecureStorage.bakaRefreshTokenKey);
                print(text);
              },
              child: const Text('read refreshToken'),
            ),
            const Divider(),
            const Text('FIREBASE'),
            FilledButton(
              onPressed: () async {
                late List<HomeworkWithID>? fireHws;
                try {
                  fireHws =
                      await ref.read(firebaseServiceProvider).getAllHomeworks();
                } catch (e) {
                  if (context.mounted) {
                    showMessage(context, e.toString(), isError: true);
                  }
                }
                if (context.mounted) {
                  showDialogAdaptive(
                      context: context,
                      content: SingleChildScrollView(
                        child: Text(fireHws.toString()),
                      ),
                      actions: [
                        adaptiveDialogButton(
                          context: context,
                          child: const Text('Close'),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        )
                      ]);
                }
              },
              child: const Text('test firebase'),
            ),
            FilledButton(
              onPressed: () async {
                ref.read(firebaseServiceProvider).logOut();
              },
              child: const Text('logout from firebase'),
            ),
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
                      if (item.isDeleted) const Icon(Icons.delete)
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
                      if (item.isCompleted) const Icon(Icons.check),
                      if (entry.value.isDeleted) const Icon(Icons.delete),
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
                      if (entry.value.isDeleted) const Icon(Icons.delete),
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
