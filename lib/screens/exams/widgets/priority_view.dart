import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/screens/exams/widgets/exam_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/animated_star.dart';
import 'package:school_manager/widgets/expansion_title.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';

class PriorityView extends StatelessWidget {
  const PriorityView({
    super.key,
    required this.examsByPriority,
    required this.completedExams,
    required this.updateView,
    required this.reorderExam,
  });

  final Map<int, List<ExamDTO>> examsByPriority;
  final List<ExamDTO> completedExams;
  final void Function() updateView;
  final Function(int oldPriority, int oldIndex, int newPriority, int newIndex)
      reorderExam;

  void _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    int oldPriority = 3 - oldListIndex;
    int newPriority = 3 - newListIndex;
    reorderExam(oldItemIndex, oldPriority, newItemIndex, newPriority);
  }

  @override
  Widget build(BuildContext context) {
    int numberOfPriorityLists = 0;
    examsByPriority.forEach(
      (priority, list) {
        if (list.isNotEmpty) numberOfPriorityLists = 4;
      },
    );
    completedExams.sort(
      (a, b) {
        return b.deadline.compareTo(a.deadline);
      },
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new exam',
        onPressed: () {
          HapticFeedback.lightImpact();
          addTask(context, isHomework: false).then(
            (value) => updateView(),
          );
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
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          children: [
            DragAndDropLists(
              disableScrolling: true,
              constrainDraggingAxis: false,
              contentsWhenEmpty: const AnimatedStar(),
              itemDivider: const SizedBox(height: 10),
              listDivider: const SizedBox(height: 10),
              lastListTargetSize: 0,
              lastItemTargetHeight: 10,
              listDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              onItemDraggingChanged: (item, dragging) {
                if (dragging) HapticFeedback.heavyImpact();
              },
              onItemReorder: _onItemReorder,
              onListReorder: (oldListIndex, newListIndex) {},
              listGhost: const Placeholder(),
              children: List.generate(
                numberOfPriorityLists,
                (index) =>
                    _buildList(TaskPriority(3 - index, context), context),
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
                      onDelete: (context) =>
                          deleteExam(context, exam.dbIndex, () => updateView())
                              .then(
                        (value) => updateView(),
                      ),
                      onEdit: () => editExam(context, exam.dbIndex).then(
                        (value) => updateView(),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  _buildList(TaskPriority priority, BuildContext context) {
    var innerList = examsByPriority[priority.index];

    return DragAndDropListExpansion(
      listKey: ObjectKey(innerList),
      title: ExpansionTitle(
        titleText: priority.name,
        titleTextColor: priority.color,
        numberOfItems: innerList!.length,
      ),
      contentsWhenEmpty: const SizedBox(),
      initiallyExpanded: true,
      canDrag: false,
      disableTopAndBottomBorders: true,
      children: List.generate(
          innerList.length, (index) => _buildItem(innerList[index], context)),
    );
  }

  _buildItem(ExamDTO exam, BuildContext context) {
    return DragAndDropItem(
      child: ExamTile(
        exam: exam,
        onDelete: (context) =>
            deleteExam(context, exam.dbIndex, () => updateView()).then(
          (value) => updateView(),
        ),
        onEdit: () => editExam(context, exam.dbIndex).then(
          (value) => updateView(),
        ),
      ),
    );
  }
}
