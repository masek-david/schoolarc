import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/screens/exams/widgets/exam_tile.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/screen_size.dart';
import 'package:school_manager/utils/task_functions.dart';
import 'package:school_manager/widgets/animated_completion.dart';
import 'package:school_manager/widgets/animated_star.dart';
import 'package:school_manager/widgets/expansion_title.dart';
import 'package:school_manager/widgets/list_bottom_spacer.dart';
import 'package:school_manager/widgets/wide_screen_app_bar.dart';

class ExamsScreen extends ConsumerStatefulWidget {
  const ExamsScreen({super.key});

  @override
  ConsumerState<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends ConsumerState<ExamsScreen> {
  final Map<int, GlobalKey<AnimatedCompletionTileState>> _tileKeys = {};

  GlobalKey getTileKey(int id) {
    return _tileKeys.putIfAbsent(
        id, () => GlobalKey<AnimatedCompletionTileState>());
  }

  @override
  Widget build(BuildContext context) {
    final examByPriority = ref.watch(examSortedProvider);
    final completedExams = ref.watch(examCompletedProvider);

    int numberOfPriorityLists = 0;
    examByPriority.forEach(
      (priority, list) {
        if (list.isNotEmpty) numberOfPriorityLists = 4;
      },
    );

    return ValueListenableBuilder(
      valueListenable: ScreenSize.isWideScreen,
      builder: (context, isWide, child) {
        return Scaffold(
          appBar: WideScreenAppBar(
            isWideScreen: isWide,
            title: const Text('Exams'),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Add new exam',
            onPressed: () async {
              HapticFeedback.lightImpact();
              addNewExam(context, ref);
            },
            enableFeedback: true,
            child: const Icon(Icons.add),
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
              child: RefreshIndicator(
                notificationPredicate: settings.get(Setting.useFirebase)
                    ? (_) => true
                    : (_) => false,
                onRefresh: () async {
                  try {
                    await ref.read(examProvider.notifier).syncAll();
                  } on Object catch (e) {
                    if (context.mounted) {
                      showMessage(context, e.toString(), isError: true);
                    }
                    return;
                  }
                },
                child: ListView(
                  children: [
                    DragAndDropLists(
                      disableScrolling: true,
                      constrainDraggingAxis: false,
                      contentsWhenEmpty: const AnimatedStar(),
                      itemDivider: const SizedBox(height: 10),
                      listDivider: const SizedBox(height: 10),
                      lastListTargetSize: 0,
                      lastItemTargetHeight: 20,
                      listDecoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onItemDraggingChanged: (item, dragging) {
                        if (dragging) HapticFeedback.heavyImpact();
                      },
                      onItemReorder: (oldItemIndex, oldListIndex, newItemIndex,
                          newListIndex) {
                        int oldPriority = 3 - oldListIndex;
                        int newPriority = 3 - newListIndex;
                        ref.read(examProvider.notifier).reorder(
                              oldItemIndex,
                              newItemIndex,
                              oldPriority,
                              newPriority,
                              null,
                              addTimestamp: true,
                            );
                      },
                      onListReorder: (oldListIndex, newListIndex) {},
                      listGhost: const Placeholder(),
                      children: List.generate(
                        numberOfPriorityLists,
                        (index) => _buildList(
                          examByPriority[3 - index]!,
                          TaskPriority(3 - index),
                          context,
                          ref,
                        ),
                      ),
                    ),
                    ExpansionTile(
                      title: ExpansionTitle(
                        numberOfItems: completedExams.length,
                        titleText: 'Completed',
                      ),
                      shape: const Border(),
                      children: List.generate(
                        completedExams.length,
                        (index) {
                          ExamDTO exam = completedExams[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ExamTile(
                              exam: exam,
                              onDelete: () => deleteExam(context, ref, exam),
                              onEdit: () => editExam(context, ref, exam),
                            ),
                          );
                        },
                      ),
                    ),
                    ListBottomSpacer(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  DragAndDropListExpansion _buildList(List<ExamDTO> list, TaskPriority priority,
      BuildContext context, WidgetRef ref) {
    return DragAndDropListExpansion(
      listKey: GlobalKey(),
      leading: SizedBox(
        width: 200,
        child: ExpansionTitle(
          titleText: priority.name,
          titleTextColor: priority.getColor(context),
          numberOfItems: null,
          // numberOfItems: list.length,
        ),
      ),
      contentsWhenEmpty: const SizedBox(),
      initiallyExpanded: true,
      disableTopAndBottomBorders: true,
      canDrag: false,
      children: List.generate(
        list.length,
        (index) => _buildItem(list[index], context, ref),
      ),
    );
  }

  DragAndDropItem _buildItem(
      ExamDTO exam, BuildContext context, WidgetRef ref) {
    return DragAndDropItem(
      feedbackWidget: ExamTile(
        exam: exam,
        onDelete: () => deleteExam(context, ref, exam),
        onEdit: () => editExam(context, ref, exam),
      ),
      child: ExamTile(
        exam: exam,
        key: getTileKey(exam.dbIndex),
        onDelete: () => deleteExam(context, ref, exam),
        onEdit: () => editExam(context, ref, exam),
      ),
    );
  }
}
