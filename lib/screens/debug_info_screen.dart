import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/database/baka_homeworks_database.dart';
import 'package:schoolarc/database/exam_database.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/database/hw_database.dart';
import 'package:schoolarc/database/secure_storage.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/database/subject_database.dart';
import 'package:schoolarc/models/homeworks/hw_data_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';

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
            Wrap(
              children: [
                M3EFilledIconButton(
                  icon: const Icon(Icons.lock_rounded),
                  onPressed: () {},
                  // size: .lg,
                ),
                const SizedBox(height: 8),
                M3EFilledIconButton.tonal(
                  icon: const Icon(Icons.lock_rounded),
                  onPressed: () {},
                  // size: .md,
                ),
                const SizedBox(height: 4),
                M3EOutlinedIconButton(
                  icon: const Icon(Icons.lock_rounded),
                  onPressed: () {},
                  // size: .sm,
                ),
                M3EIconButton(
                  icon: const Icon(Icons.lock_rounded),
                  onPressed: () {},
                  // size: .xs,
                ),
              ],
            ),
            M3EElevatedButton.icon(
              icon: const Icon(Icons.lock_rounded),
              onPressed: () {},
              size: .xl,
              label: const Text('Elevated'),
            ),
            const SizedBox(height: 8),
            M3EFilledButton.icon(
              icon: const Icon(Icons.lock_rounded),
              onPressed: () {},
              size: .lg,
              label: const Text('Filled'),
            ),
            const SizedBox(height: 8),
            M3EFilledButton.tonalIcon(
              icon: const Icon(Icons.lock_rounded),
              onPressed: () {},
              size: .md,
              label: const Text('Tonal'),
            ),
            const SizedBox(height: 4),
            M3EOutlinedButton.icon(
              icon: const Icon(Icons.lock_rounded),
              onPressed: () {},
              size: .sm,
              label: const Text('Outlined'),
            ),
            M3ETextButton.icon(
              icon: const Icon(Icons.lock_rounded),
              onPressed: () {},
              size: .xs,
              label: const Text('Text'),
            ),
            const SizedBox(height: 50),
            M3EFilledButton(
              onPressed: () {
                settings.save(.onboardingProgress, 0);
              },
              child: const Text('Launch welcome screen on next open'),
            ),
            M3EFilledButton.tonal(
              onPressed: () {
                throw Exception('Crash button pressed');
              },
              child: const Text('Crash'),
            ),
            const Padding(
              padding: EdgeInsetsGeometry.all(8),
              child: Text(
                bool.fromEnvironment('dart.tool.dart2wasm')
                    ? 'Running in wasm'
                    : 'Not running in wasm',
              ),
            ),
            if (kDebugMode)
              M3EFilledButton.tonalIcon(
                onPressed: () {
                  HomeworksDatabase().deleteBoxFromDisk();
                  SubjectDatabase().deleteAllFromDisk();
                  ExamDatabase().deleteAllFromDisk();
                  SettingsDatabase().deleteAllFromDisk();
                  BakaHomeworksDatabase().deleteAllFromDisk();
                },
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Delete all boxes from disk'),
              ),
            if (kDebugMode)
              M3EFilledButton.icon(
                onPressed: () async {
                  SettingsDatabase().deleteAllFromDisk();
                  await Hive.openBox(settingsBox);
                  await bakaService.logOut();
                  await stravaService.logOut();
                  await fireService.logOut();
                  SecureStorage.deleteAllFromDisk();
                },
                icon: const Icon(Icons.bug_report),
                label: const Text(
                  'Reset all settings and log out (run app as new, keep only hw, exam, subjects) ',
                ),
              ),
            const Divider(),
            Text(
              vibrate.hasVibrator ? 'Has vibrator' : 'Doesn\'t have vibrator',
            ),
            Wrap(
              spacing: 4,
              children: [
                M3EFilledButton.tonal(
                  onPressed: vibrate.light,
                  child: const Text('Light'),
                ),
                M3EFilledButton.tonal(
                  onPressed: vibrate.medium,
                  child: const Text('Medium'),
                ),
                M3EFilledButton.tonal(
                  onPressed: vibrate.heavy,
                  child: const Text('Heavy'),
                ),
                M3EFilledButton.tonal(
                  onPressed: vibrate.success,
                  child: const Text('Success'),
                ),
                M3EFilledButton.tonal(
                  onPressed: vibrate.warning,
                  child: const Text('Warning'),
                ),
                M3EFilledButton.tonal(
                  onPressed: vibrate.error,
                  child: const Text('Error'),
                ),
                M3EFilledButton.tonal(
                  onPressed: vibrate.rigid,
                  child: const Text('Rigid'),
                ),
                M3EFilledButton.tonal(
                  onPressed: () => vibrate.complete(true),
                  child: const Text('Complete'),
                ),
                M3EFilledButton.tonal(
                  onPressed: vibrate.release,
                  child: const Text('Release'),
                ),
                M3EFilledButton.tonal(
                  onPressed: vibrate.releaseLong,
                  child: const Text('Release long'),
                ),
                M3EFilledButton.tonal(
                  onPressed: () => vibrate.switchUI(true),
                  child: const Text('Switch'),
                ),
              ],
            ),
            if (kDebugMode) const Divider(),
            const Text('SECURE STORAGE'),
            Row(
              spacing: 8,
              children: [
                Expanded(
                  child: M3EFilledButton(
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
                  child: M3EFilledButton(
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
            M3EFilledButton(
              onPressed: () async {
                late List<HomeworkData>? fireHws;
                try {
                  fireHws = await fireService.getAllHomeworks();
                } catch (e) {
                  if (context.mounted) {
                    showErrorMessage(context, e);
                  }
                }
                if (context.mounted) {
                  showMyDialog(
                    context: context,
                    content: SingleChildScrollView(
                      child: Text(fireHws.toString()),
                    ),
                    actions: [
                      DialogActionButton(
                        text: 'Close',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                }
              },
              child: const Text('Test Firebase'),
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
