import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/services/firestore/firestore_service.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/screens/subjects/widgets/new_subject_dialog.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';

class SubjectsScreen extends ConsumerStatefulWidget {
  const SubjectsScreen({super.key});

  @override
  ConsumerState<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends ConsumerState<SubjectsScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController shortcutController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    shortcutController.dispose();

    super.dispose();
  }

  void createNewSubject(WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => SubjectDialog(
        text: 'Add new subject',
        nameController: nameController,
        shortcutController: shortcutController,
        onSave: () async {
          ref.read(subjectNotifier.notifier).saveNew(
                Subject(
                  name: nameController.text,
                  shortcut: shortcutController.text,
                  fireId: null,
                  isDeleted: false,
                  timestamp: Timestamp.now().toDate(),
                  bakaId: null,
                  order: 0,
                ),
              );
        },
      ),
    ).then(
      (value) => {
        nameController.clear(),
        shortcutController.clear(),
      },
    );
  }

  void editSubject(SubjectDTO subject, WidgetRef ref) {
    nameController.text = subject.name;
    shortcutController.text = subject.shortcut;

    showDialog(
      context: context,
      builder: (context) => SubjectDialog(
        text: 'Edit subject',
        nameController: nameController,
        shortcutController: shortcutController,
        onSave: () {
          SubjectDTO newSubject = SubjectDTO(
            name: nameController.text,
            shortcut: shortcutController.text,
            dbIndex: subject.dbIndex,
            bakaId: subject.bakaId,
            isDeleted: subject.isDeleted,
            fireId: subject.fireId,
            timestamp: Timestamp.now(),
            order: subject.order,
          );

          ref.read(subjectNotifier.notifier).edit(newSubject);
        },
      ),
    ).then(
      (value) => {
        nameController.clear(),
        shortcutController.clear(),
      },
    );
  }

  void deleteSubject(int dbIndex, WidgetRef ref) {
    ref.read(subjectNotifier.notifier).deleteSubject(dbIndex);

    showMessage(context, 'Subject deleted', actions: [
      SnackBarAction(
        label: 'Undo',
        onPressed: () {
          ref.read(subjectNotifier.notifier).revertDelete(dbIndex);
        },
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        actions: [
          if (settings.get(Setting.showDebugInfo))
            TextButton(
              onPressed: () {
                setState(() {
                  showDialogAdaptive(
                    context: context,
                    title: const Text('Delete all subjects?'),
                    actions: [
                      adaptiveDialogButton(
                        context: context,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Close'),
                      ),
                      adaptiveDialogButton(
                        context: context,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  );
                });
              },
              child: const Text('Delete all'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new subject',
        onPressed: () {
          HapticFeedback.mediumImpact();
          createNewSubject(ref);
        },
        child: const Icon(Icons.add),
      ),
      body: SlidableAutoCloseBehavior(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Consumer(builder: (context, ref, child) {
            final subjects = ref.watch(subjectsSortedNotifier);

            return subjects.isEmpty
                ? const Center(
                    child: Text(
                      'No subjects found. You can create new subjects by tapping the plus button.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : RefreshIndicator(
                    notificationPredicate: settings.get(Setting.useFirebase)
                        ? (_) => true
                        : (_) => false,
                    onRefresh: () async {
                      try {
                        return await FirestoreService().syncSubjects();
                      } on Object catch (e) {
                        if (context.mounted) {
                          showMessage(context, e.toString(), isError: true);
                        }
                        return;
                      }
                    },
                    child: ReorderableListView.builder(
                      onReorderStart: (index) => HapticFeedback.lightImpact(),
                      itemCount: subjects.length + 1,
                      itemBuilder: (context, index) {
                        if (index == subjects.length) {
                          return const SizedBox(
                            height: 100,
                            key: Key('SubjectScreenSpacer'),
                          );
                        }

                        SubjectDTO subject = subjects[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          key: Key('$index'),
                          child: SubjectTile(
                            subject: subject,
                            onTap: () => editSubject(subject, ref),
                            onDelete: () => deleteSubject(subject.dbIndex, ref),
                          ),
                        );
                      },
                      onReorder: (int oldIndex, int newIndex) {
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }

                        ref.read(subjectNotifier.notifier).reorder(
                              oldIndex,
                              newIndex,
                              null,
                              addTimestamp: true,
                            );
                      },
                    ),
                  );
          }),
        ),
      ),
    );
  }
}
