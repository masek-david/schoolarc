import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/use_cloudsync_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/task_functions.dart';
import 'package:schoolarc/widgets/animated_shape.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_refresh_indicator.dart';
import 'package:schoolarc/widgets/lists/title_with_count.dart';
import 'package:schoolarc/widgets/snappable.dart';
import 'package:schoolarc/widgets/tiles/exam_tile.dart';
import 'package:schoolarc/widgets/web_request_focus.dart';

class _AnimatedReorderableListItem {
  _AnimatedReorderableListItem({this.exam, this.priority}) {
    assert(exam != null || priority != null);
  }

  Exam? exam;
  int? priority;

  int get getPriority {
    if (priority != null) {
      return priority!;
    }
    return exam!.priority.index;
  }

  @override
  String toString() {
    return '${exam != null ? exam.toString() : ''} ${priority != null ? priority!.toString() : ''}';
  }

  bool isSameAs(_AnimatedReorderableListItem other) {
    if (priority != null && other.priority != null) {
      return priority! == other.priority!;
    }

    if (exam != null && other.exam != null) {
      return exam!.id == other.exam!.id;
    }

    return false;
  }
}

class ExamsScreen extends ConsumerWidget {
  const ExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final examByPriority = ref.watch(examSortedProvider);
    final completedExams = ref.watch(examCompletedProvider);

    final itemList = <_AnimatedReorderableListItem>[];
    for (int i = 3; i >= 0; i--) {
      itemList.add(_AnimatedReorderableListItem(priority: i));
      itemList.addAll(
        examByPriority[i]!.map((e) => _AnimatedReorderableListItem(exam: e)),
      );
    }
    itemList.add(_AnimatedReorderableListItem(priority: -1));
    final nonDraggableItems = itemList
        .where((element) => element.exam == null)
        .toList();

    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: Scaffold(
        // floatingActionButton: const NewTaskDialogButton(),
        floatingActionButton: WebRequestFocusBuilder(
          builder: (showKeyboard) {
            return FloatingActionButton(
              tooltip: context.loc.addNewExam,
              onPressed: () async {
                showKeyboard();
                vibrate.medium();
                addNewExam(context);
              },
              enableFeedback: true,
              child: const Icon(Icons.add),
            );
          }
        ),
        body: Theme(
          data: Theme.of(context).copyWith(
            listTileTheme: ListTileTheme.of(context).copyWith(
              dense: true,
              visualDensity: VisualDensity.compact,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ExpressiveRefreshIndicator(
              enabled: ref.watch(useCloudSyncProvider) ? true : false,
              onRefresh: () async {
                try {
                  await ref.read(examDataProvider.notifier).syncAll();
                } on Object catch (e) {
                  if (context.mounted) {
                    showErrorMessage(context,e);
                  }
                  return;
                }
              },
              child: itemList.length == 5
                  ? ListView(
                      children: [
                        const Snappable(child: AnimatedShape()),
                        _buildCompletedList(context, ref, completedExams),
                      ],
                    )
                  : AnimatedReorderableListView(
                      items: itemList,
                      buildDefaultDragHandles: false,
                      lockedItems: [
                        _AnimatedReorderableListItem(priority: 3),
                        _AnimatedReorderableListItem(priority: -1),
                      ],
                      nonDraggableItems: nonDraggableItems,
                      onReorderStart: (p0) => vibrate.medium(),
                      itemBuilder: (context, index) {
                        final item = itemList[index];

                        if (item.priority != null) {
                          if (item.priority! == -1) {
                            return _buildCompletedList(
                              context,
                              ref,
                              completedExams,
                            );
                          }

                          final priority = TaskPriority(item.priority!);
                          return Padding(
                            key: ValueKey('exam title: ${item.priority!}'),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: TitleWithCount(
                              text: priority.name(context),
                              textColor: priority.getColor(context),
                            ),
                          );
                        }

                        final exam = item.exam!;
                        return Padding(
                          // stateReaddingVersion needs to be here, it changes when the task is re-added, so it doesnt trigger
                          // Multiple widgets use the same globalkey error
                          key: ValueKey(
                            'exam: ${exam.id} ${exam.stateReaddingVersion}',
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ExamTile(
                            exam: exam,
                            onDelete: () => deleteExam(context, ref, exam),
                            onEdit: () => editExam(context, exam),
                            onConvert: () => convertExam(context, ref, exam),
                          ),
                        );
                      },
                      isSameItem: (a, b) => a.isSameAs(b),
                      onReorder: (oldIndex, newIndex) {
                        final item = itemList.removeAt(oldIndex);

                        final newPriority = itemList[newIndex - 1].getPriority;

                        int newOrder = 0;
                        for (int i = 0; i < newIndex; i++) {
                          if (itemList[i].exam?.priority.index == newPriority) {
                            newOrder++;
                          }
                        }

                        if (item.exam != null) {
                          ref
                              .read(examDataProvider.notifier)
                              .reorder(
                                item.exam!.toData(),
                                newOrder,
                                newPriority,
                              );
                        }
                      },
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedList(
    BuildContext context,
    WidgetRef ref,
    List<Exam> completedExams,
  ) {
    return Padding(
      key: const ValueKey('exam completed title'),
      padding: const EdgeInsets.only(bottom: 70),
      child: ExpansionTile(
        title: TitleWithCount(
          count: completedExams.length,
          text: context.loc.completed,
        ),
        shape: const Border(),
        children: List.generate(
          completedExams.length,
          (index) {
            final exam = completedExams[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ExamTile(
                exam: exam,
                onDelete: () => deleteExam(context, ref, exam),
                onEdit: () => editExam(context, exam),
                onConvert: () => convertExam(context, ref, exam),
              ),
            );
          },
        ),
      ),
    );
  }
}
