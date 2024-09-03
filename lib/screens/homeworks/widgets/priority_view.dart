import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/widgets/completed_star.dart';
import 'package:school_manager/widgets/expansion_title.dart';
import 'package:school_manager/data/priority_model.dart';

class PriorityView extends StatelessWidget {
  const PriorityView({
    super.key,
    required this.hwByPriority,
    required this.completedHws,
    required this.createNewHw,
    required this.changeCompletion,
    required this.deleteHw,
    required this.editHw,
    required this.reorderHomework,
  });

  final Map<int, List<HomeworkDTO>> hwByPriority;
  final List<HomeworkDTO> completedHws;
  final Function createNewHw;
  final Function(int hwDbIndex, bool value) changeCompletion;
  final Function(int hwDbIndex) editHw;
  final Function(int hwDbIndex) deleteHw;
  final Function(int oldPriority, int oldIndex, int newPriority, int newIndex)
      reorderHomework;

  void _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    int oldPriority = 3 - oldListIndex;
    int newPriority = 3 - newListIndex;
    reorderHomework(oldItemIndex, oldPriority, newItemIndex, newPriority);
  }

  @override
  Widget build(BuildContext context) {
    int numberOfPriorityLists = 0;
    hwByPriority.forEach(
      (priority, list) {
        if (list.isNotEmpty) numberOfPriorityLists = 4;
      },
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createNewHw();
          HapticFeedback.lightImpact();
        },
        enableFeedback: true,
        child: const Icon(Icons.add),
      ),
      body: SlidableAutoCloseBehavior(
        child: Theme(
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
                contentsWhenEmpty: const CompletedStar(),
                itemDivider: const SizedBox(height: 10),
                listDivider: const SizedBox(height: 10),
                lastListTargetSize: 0,
                lastItemTargetHeight: 10,
                listDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  // color: Theme.of(context).colorScheme.primary.withAlpha(20),
                ),
                onItemDraggingChanged: (item, dragging) {
                  if (dragging) HapticFeedback.heavyImpact();
                },
                onItemReorder: _onItemReorder,
                onListReorder: (oldListIndex, newListIndex) {},
                listGhost: const Placeholder(),
                children: List.generate(
                  numberOfPriorityLists,
                  (index) => _buildList(Priority(3 - index, context), context),
                ),
              ),
              ExpansionTile(
                title: ExpansionTitle(
                  numberOfItems: completedHws.length,
                  titleText: 'Completed',
                  titleTextColor: Theme.of(context).colorScheme.inverseSurface,
                ),
                shape: const Border(),
                children: List.generate(
                  completedHws.length,
                  (index) {
                    HomeworkDTO hw = completedHws[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: HomeworkTile(
                        text: hw.text,
                        subject: hw.subject,
                        completion: hw.completion,
                        priority: Priority(hw.priority, context),
                        deadline: hw.deadline,
                        onChangedCompletion: (value) => changeCompletion(hw.dbIndex, value),
                        onDelete: () => deleteHw(hw.dbIndex),
                        onEdit: () => editHw(hw.dbIndex),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }

  _buildList(Priority priority, BuildContext context) {
    var innerList = hwByPriority[priority.index];

    return DragAndDropListExpansion(
      listKey: ObjectKey(innerList),
      title: ExpansionTitle(
        titleText: priority.name,
        titleTextColor: priority.color,
        numberOfItems: innerList!.length,
      ),
      contentsWhenEmpty: const SizedBox(),
      // backgroundColor: Theme.of(context).colorScheme.surface,
      initiallyExpanded: true,
      canDrag: false,
      disableTopAndBottomBorders: true,
      children: List.generate(
          innerList.length, (index) => _buildItem(innerList[index], context)),
    );
  }

  _buildItem(HomeworkDTO hw, BuildContext context) {
    return DragAndDropItem(
      child: HomeworkTile(
        text: hw.text,
        subject: hw.subject,
        completion: hw.completion,
        priority: Priority(hw.priority, context),
        deadline: hw.deadline,
        onChangedCompletion: (value) => changeCompletion(hw.dbIndex, value),
        onDelete: () => deleteHw(hw.dbIndex),
        onEdit: () => editHw(hw.dbIndex),
      ),
    );
  }
}
