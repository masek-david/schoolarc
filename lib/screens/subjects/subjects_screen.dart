import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/provider/use_cloudsync_notifier.dart';
import 'package:schoolarc/screens/subjects/widgets/new_subject_dialog.dart';
import 'package:schoolarc/screens/subjects/widgets/subject_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_refresh_indicator.dart';
import 'package:schoolarc/widgets/web_request_focus.dart';

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  void deleteSubject(BuildContext context, WidgetRef ref, Subject subject) {
    ref.read(subjectsProvider.notifier).delete(subject);

    showMessage(
      context,
      context.loc.deletedSubjectMessage(subject.name),
      actions: [
        SnackBarAction(
          label: context.loc.undo,
          onPressed: () {
            ref.read(subjectsProvider.notifier).revertDelete(subject);
          },
        ),
      ],
    );
  }

  Future<void> onRefresh(BuildContext context, WidgetRef ref) async {
    try {
      return await ref.read(subjectsProvider.notifier).syncAll();
    } on Object catch (e) {
      if (context.mounted) {
        showErrorMessage(context, e);
      }
      return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final map = ref.read(subjectsUsedTimesProvider);
    final subjects = ref.watch(subjectsSortedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.subjects),
        actions: [
          if (kIsWeb && ref.watch(useCloudSyncProvider))
            IconButton(
              onPressed: () => onRefresh(context, ref),
              icon: const Icon(Icons.refresh_outlined),
            ),
        ],
      ),
      floatingActionButton: WebRequestFocusBuilder(
        builder: (showKeyboard) {
          return FloatingActionButton(
            tooltip: context.loc.addNewSubject,
            onPressed: () {
              showKeyboard();
              vibrate.medium();
              addNewSubject(context);
            },
            child: const Icon(Icons.add_rounded),
          );
        },
      ),
      body: SlidableAutoCloseBehavior(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: subjects.isEmpty
              ? EmptyMessage(
                message: context.loc.noSubjectsMessage,
              )
              : ExpressiveRefreshIndicator(
                  enabled: ref.watch(useCloudSyncProvider) ? true : false,
                  onRefresh: () => onRefresh(context, ref),
                  child: AnimatedReorderableListView(
                    onReorderStart: (index) => vibrate.medium(),
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
                          onTap: () {
                            final map = ref.read(subjectsUsedTimesProvider);
                            final usedTimes = map[subject.id];

                            editSubject(context, subject, usedTimes: usedTimes);
                          },
                          onDelete: () => deleteSubject(context, ref, subject),
                        ),
                      );
                    },
                    onReorder: (int oldIndex, int newIndex) {
                      ref
                          .read(subjectsProvider.notifier)
                          .reorder(
                            subjects[oldIndex],
                            newIndex,
                          );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}
