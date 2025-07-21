import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/models/subjects/subject_entity_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/provider/cloudsync_notifier.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/screens/empty_message.dart';
import 'package:school_manager/screens/subjects/widgets/new_subject_dialog.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

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
        text: context.loc.addNewSubject,
        nameController: nameController,
        shortcutController: shortcutController,
        onSave: () async {
          ref.read(subjectsProvider.notifier).saveNew(
                SubjectEntity(
                  name: nameController.text,
                  shortcut: shortcutController.text,
                  isDeleted: false,
                  timestamp: DateTime.now().toUtc(),
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

  void editSubject(Subject subject, WidgetRef ref) {
    nameController.text = subject.name;
    shortcutController.text = subject.shortcut;

    final map = ref.read(subjectsUsedTimesProvider);
    final usedTimes = map[subject.id];

    showDialog(
      context: context,
      builder: (context) => SubjectDialog(
        text: context.loc.editSubject,
        nameController: nameController,
        shortcutController: shortcutController,
        usedTimes: usedTimes,
        onSave: () {
          Subject newSubject = Subject(
            name: nameController.text,
            shortcut: shortcutController.text,
            id: subject.id,
            bakaId: subject.bakaId,
            isDeleted: subject.isDeleted,
            timestamp: DateTime.now().toUtc(),
            order: subject.order,
          );

          ref.read(subjectsProvider.notifier).edit(newSubject);
        },
      ),
    ).then(
      (value) => {
        nameController.clear(),
        shortcutController.clear(),
      },
    );
  }

  void deleteSubject(Subject subject, WidgetRef ref) {
    ref.read(subjectsProvider.notifier).deleteSubject(subject);

    showMessage(context, context.loc.deletedSubjectMessage(subject.name),
        actions: [
          SnackBarAction(
            label: context.loc.undo,
            onPressed: () {
              ref.read(subjectsProvider.notifier).revertDelete(subject);
            },
          ),
        ]);
  }

  Future<void> onRefresh() async {
    try {
      return await ref.read(subjectsProvider.notifier).syncAll();
    } on Object catch (e) {
      if (context.mounted) {
        showMessage(context, e.toString(), isError: true);
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final map = ref.read(subjectsUsedTimesProvider);
    final subjects = ref.watch(subjectsSortedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.subjects),
        actions: [
          if (kIsWeb && ref.watch(useCloudSyncProvider))
            IconButton(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_outlined),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: context.loc.addNewSubject,
        onPressed: () {
          HapticFeedback.mediumImpact();
          createNewSubject(ref);
        },
        child: const Icon(Icons.add),
      ),
      body: SlidableAutoCloseBehavior(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: subjects.isEmpty
              ? EmptyMessage(
                  message: context.loc.noSubjectsFoundMessage,
                )
              : RefreshIndicator(
                  notificationPredicate: ref.watch(useCloudSyncProvider)
                      ? (_) => true
                      : (_) => false,
                  onRefresh: onRefresh,
                  child: AnimatedReorderableListView(
                    onReorderStart: (index) => HapticFeedback.mediumImpact(),
                    items: subjects,
                    isSameItem: (a, b) => a.id == b.id,
                    padding: const EdgeInsets.only(bottom: 100),
                    itemBuilder: (context, index) {
                      Subject subject = subjects[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        key: Key('Sub: ${subject.id}'),
                        child: SubjectTile(
                          usedTimes: map[subject.id],
                          subject: subject,
                          onTap: () => editSubject(subject, ref),
                          onDelete: () => deleteSubject(subject, ref),
                        ),
                      );
                    },
                    onReorder: (int oldIndex, int newIndex) {
                      ref.read(subjectsProvider.notifier).reorder(
                            newIndex,
                            subjects[oldIndex],
                            addTimestamp: true,
                          );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
