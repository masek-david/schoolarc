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
            const Text(bool.fromEnvironment('dart.tool.dart2wasm') ? 'Running in wasm' : 'Not running in wasm'),
            if (kDebugMode)
              FilledButton.tonalIcon(
                onPressed: () {
                  HomeworksDatabase().deleteAllFromDisk();
                  SubjectDatabase().deleteAllFromDisk();
                  ExamDatabase().deleteAllFromDisk();
                  SettingsDatabase().deleteAllFromDisk();
                  BakaHomeworksDatabase().deleteAllFromDisk();
                },
                label: const Text('delete from disk'),
                icon: const Icon(Icons.bug_report),
              ),
            if (kDebugMode) const SizedBox(height: 8),
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
            if (kDebugMode) const Divider(),
            const Text('SECURE STORAGE'),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: FilledButton(
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
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final text = await secureStorage.read('test');
                      if (context.mounted) {
                        showMessage(context, text);
                      }
                    },
                    child: const Text('read test'),
                  ),
                ),
              ],
            ),
            const Divider(),
            const Text('FIREBASE'),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      late List<HomeworkEntityWithID>? fireHws;
                      try {
                        fireHws = await ref
                            .read(firebaseServiceProvider)
                            .getAllHomeworks();
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
                ),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      ref.read(firebaseServiceProvider).logOut();
                    },
                    child: const Text('logout from firebase'),
                  ),
                ),
              ],
            ),
            const Text('SUBJECTS'),
            const Divider(),
            ...subjects.entries.map((entry) {
              var item = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    idText(entry.key, context),
                    SizedBox(
                      width: 60,
                      child: Center(child: Text(item.shortcut)),
                    ),
                    Expanded(child: Text(item.name)),
                    SizedBox(
                      width: 20,
                      child: Text(item.bakaId ?? ''),
                    ),
                    SizedBox(
                      width: 20,
                      child: item.isDeleted ? const Icon(Icons.delete) : null,
                    ),
                    SizedBox(
                      width: 20,
                      child: item.isShared ? const Icon(Icons.share) : null,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 50),
            const Text('HOMEWORKS'),
            const Divider(),
            ...hws.entries.map((entry) {
              var item = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    idText(entry.key, context),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        item.priority.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: TaskPriority(item.priority).color,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.text),
                          Text(
                            item.deadline.toString(),
                            style:
                                TextStyle(color: getSubtleTextColor(context)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20,
                      child: item.isDeleted ? const Icon(Icons.delete) : null,
                    ),
                    SizedBox(
                      width: 20,
                      child: item.isShared ? const Icon(Icons.share) : null,
                    ),
                    SizedBox(
                      width: 20,
                      child: item.isCompleted ? const Icon(Icons.check) : null,
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 50),
            const Text('EXAMS'),
            const Divider(),
            ...exams.entries.map(
              (entry) {
                var item = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      idText(entry.key, context),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          item.priority.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TaskPriority(item.priority).color,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item.text),
                            Text(
                              item.date.toString(),
                              style:
                                  TextStyle(color: getSubtleTextColor(context)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                        child: item.isDeleted ? const Icon(Icons.delete) : null,
                      ),
                      SizedBox(
                        width: 20,
                        child: item.isShared ? const Icon(Icons.share) : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  SizedBox idText(String entry, BuildContext context) {
    return SizedBox(
      width: 40,
      child: Text(
        entry,
        maxLines: 2,
        style: TextStyle(color: getSubtleTextColor(context)),
      ),
    );
  }
}
