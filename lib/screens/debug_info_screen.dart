import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/baka_homeworks_database.dart';
import 'package:schoolarc/database/exam_database.dart';
import 'package:schoolarc/database/hw_database.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/database/subject_database.dart';
import 'package:schoolarc/models/homeworks/homework_entity_id_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/show_adaptive_dialog.dart';

class DbInfoScreen extends ConsumerWidget {
  const DbInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exams = examsDb.getDatabase();
    final hws = homeworksDb.getDatabase();
    final subjects = subjectsDb.getDatabase();

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: [
            if (kDebugMode)
              FilledButton.tonalIcon(
                onPressed: () {
                  HomeworksDatabase().deleteAllFromDisk();
                  SubjectDatabase().deleteAllFromDisk();
                  ExamDatabase().deleteAllFromDisk();
                  SettingsDatabase().deleteAllFromDisk();
                  BakaHomeworksDatbase().deleteAllFromDisk();
                },
                label: const Text('delete from disk'),
                icon: const Icon(Icons.bug_report),
              ),
            const SizedBox(height: 8),
            if (kDebugMode)
              FilledButton.tonalIcon(
                onPressed: () {
                  bakaService.logOut();
                  stravaService.logOut();
                  ref.read(firebaseServiceProvider).logOut();
                  secureStorage.deleteAllFromDisk();
                },
                label: const Text('sign out everywhere'),
                icon: const Icon(Icons.bug_report),
              ),
            const Divider(),
            const Text('SECURE STORAGE'),
            FilledButton(
              onPressed: () async {
                try {
                  await secureStorage.write('test',
                      'this was the saved value at time: ${DateTime.now()}');
                } catch (e) {
                  if (context.mounted) {
                    showMessage(context, e.toString());
                  }
                  return;
                }
                if (context.mounted) {
                  showMessage(context, 'success');
                }
              },
              child: const Text('write test'),
            ),
            FilledButton(
              onPressed: () async {
                final text = await secureStorage.read('test');
                if (context.mounted) {
                  showMessage(context, text);
                }
              },
              child: const Text('read test'),
            ),
            const Divider(),
            const Text('FIREBASE'),
            FilledButton(
              onPressed: () async {
                late List<HomeworkEntityWithID>? fireHws;
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
