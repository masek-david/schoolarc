import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:schoolarc/database/baka_homeworks_database.dart';
import 'package:schoolarc/database/exam_database.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/database/hw_database.dart';
import 'package:schoolarc/database/secure_storage.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/database/subject_database.dart';
import 'package:schoolarc/models/homeworks/hw_data_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/show_adaptive_dialog.dart';

class DbInfoScreen extends ConsumerWidget {
  const DbInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exams = examsDb.readDatabase();
    final hws = homeworksDb.readDatabase();
    final subjects = subjectsDb.readDatabase();

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ListView(
          children: [
            FilledButton(
              onPressed: () {
                settings.save(.onboardingProgress, 0);
              },
              child: const Text('Launch welcome screen on next open'),
            ),
            const Text(
              bool.fromEnvironment('dart.tool.dart2wasm')
                  ? 'Running in wasm'
                  : 'Not running in wasm',
            ),
            if (kDebugMode)
              FilledButton.tonalIcon(
                onPressed: () {
                  HomeworksDatabase().deleteBoxFromDisk();
                  SubjectDatabase().deleteAllFromDisk();
                  ExamDatabase().deleteAllFromDisk();
                  SettingsDatabase().deleteAllFromDisk();
                  BakaHomeworksDatabase().deleteAllFromDisk();
                },
                label: const Text('Delete all boxes from disk'),
                icon: const Icon(Icons.bug_report),
              ),
            if (kDebugMode)
              FilledButton.tonalIcon(
                onPressed: () async {
                  SettingsDatabase().deleteAllFromDisk();
                  await Hive.openBox(settingsBox);
                  await bakaService.logOut();
                  await stravaService.logOut();
                  await ref.read(firebaseServiceProvider).logOut();
                  SecureStorage.deleteAllFromDisk();
                },
                label: const Text('Reset all settings (run app as new)'),
                icon: const Icon(Icons.bug_report),
              ),
            if (kDebugMode)
              FilledButton.tonalIcon(
                onPressed: () {
                  bakaService.logOut();
                  stravaService.logOut();
                  ref.read(firebaseServiceProvider).logOut();
                  SecureStorage.deleteAllFromDisk();
                },
                label: const Text('Sign out everywhere'),
                icon: const Icon(Icons.bug_report),
              ),
            const Divider(),
            Text(
              vibrate.hasVibrator ? 'Has vibrator' : 'Doesn\'t have vibrator',
            ),
            Wrap(
              children: [
                FilledButton.tonal(
                  onPressed: vibrate.light,
                  child: const Text('Light'),
                ),
                FilledButton.tonal(
                  onPressed: vibrate.medium,
                  child: const Text('Medium'),
                ),
                FilledButton.tonal(
                  onPressed: vibrate.heavy,
                  child: const Text('Heavy'),
                ),
                FilledButton.tonal(
                  onPressed: vibrate.success,
                  child: const Text('Success'),
                ),
                FilledButton.tonal(
                  onPressed: vibrate.warning,
                  child: const Text('Warning'),
                ),
                FilledButton.tonal(
                  onPressed: vibrate.error,
                  child: const Text('Error'),
                ),
                FilledButton.tonal(
                  onPressed: vibrate.rigid,
                  child: const Text('Rigid'),
                ),
              ],
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
                        await SecureStorage.write(
                          'test',
                          'this was the saved value at time: ${DateTime.now()}',
                        );
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
                      final text = await SecureStorage.read('test');
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
                      late List<HomeworkData>? fireHws;
                      try {
                        fireHws = await ref
                            .read(firebaseServiceProvider)
                            .getAllHomeworks();
                      } catch (e) {
                        if (context.mounted) {
                          showErrorMessage(context, e);
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
                            ),
                          ],
                        );
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
                            item.date.toString(),
                            style: TextStyle(
                              color: getSubtleTextColor(context),
                            ),
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
                              style: TextStyle(
                                color: getSubtleTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 20,
                        child: item.isDeleted ? const Icon(Icons.delete) : null,
                      ),
                      const SizedBox(
                        width: 20,
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
