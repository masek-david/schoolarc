import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/homeworks/data/hw_dto_model.dart';
import 'package:school_manager/homeworks/util/homework_tile.dart';
import 'package:school_manager/util/completed_star.dart';
import 'package:school_manager/util/expansion_title.dart';
import 'package:school_manager/util/priority_model.dart';

class PriorityView extends StatefulWidget {
  const PriorityView({
    super.key,
    required this.hwByPriority,
    required this.completedHws,
    required this.createNewHw,
    required this.changeCompletion,
    required this.deleteHw,
    required this.editHw,
    required this.changeSequence,
  });

  final Map<int, List<HomeworkDTO>> hwByPriority;
  final List<HomeworkDTO> completedHws;
  final Function createNewHw;
  final Function(int hwIndex) changeCompletion;
  final Function(int hwIndex) editHw;
  final Function(int hwIndex) deleteHw;
  final Function(int oldPriority, int oldIndex, int newPriority, int newIndex)
      changeSequence;

  @override
  State<PriorityView> createState() => _PriorityViewState();
}

class _PriorityViewState extends State<PriorityView> {
  void _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    int oldPriority = 3 - oldListIndex;
    int newPriority = 3 - newListIndex;
    setState(() {
      var movedItem = widget.hwByPriority[oldPriority]!.removeAt(oldItemIndex);
      movedItem.priority = newPriority;
      widget.hwByPriority[newPriority]!.insert(newItemIndex, movedItem);
    });
    widget.changeSequence(oldPriority, oldItemIndex, newPriority, newItemIndex);
  }

  /// removes hw from db and ui
  void _removeHw(HomeworkDTO hw) {
    widget.deleteHw(hw.key);

    if (hw.completion) {
      setState(() {
        widget.completedHws.remove(hw);
      });
    } else {
      setState(() {
        widget.hwByPriority[hw.priority]!.remove(hw);
      });
    }
  }

  // void addAt(HomeworkDTO hw) {
  //   setState(() {
  //     widget.hwByPriority[hw.priority]!.remove(hw);
  //   });
  // }

  void changeCompletion(HomeworkDTO hw) {
    widget.changeCompletion(hw.key);
    hw.completion = !hw.completion;

    if (hw.completion) {
      setState(() {
        widget.hwByPriority[hw.priority]!.remove(hw);
        widget.completedHws.insert(0, hw);
      });
    } else {
      setState(() {
        widget.hwByPriority[hw.priority]!.add(hw);
        widget.completedHws.remove(hw);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int numberOfPriorityLists = 0;
    widget.hwByPriority.forEach(
      (key, value) {
        if (value.isNotEmpty) numberOfPriorityLists = 4;
      },
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.createNewHw();
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
                  (index) => _buildList(Priority(3 - index, context)),
                ),
              ),
              ExpansionTile(
                title: ExpansionTitle(
                  numberOfItems: widget.completedHws.length,
                  titleText: 'Completed',
                  titleTextColor: Theme.of(context).colorScheme.inverseSurface,
                ),
                shape: const Border(),
                children: List.generate(
                  widget.completedHws.length,
                  (index) {
                    HomeworkDTO hw = widget.completedHws[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: HomeworkTile(
                        text: hw.text,
                        subject: hw.subject,
                        completion: hw.completion,
                        priority: Priority(hw.priority, context),
                        deadline: hw.deadline,
                        onChangedCompletion: (p0) => changeCompletion(hw),
                        onDelete: () => _removeHw(hw),
                        onEdit: () => widget.editHw(hw.key),
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

  _buildList(Priority priority) {
    var innerList = widget.hwByPriority[priority.index];

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
          innerList.length, (index) => _buildItem(innerList[index])),
    );
  }

  _buildItem(HomeworkDTO hw) {
    return DragAndDropItem(
      child: HomeworkTile(
        text: hw.text,
        subject: hw.subject,
        completion: hw.completion,
        priority: Priority(hw.priority, context),
        deadline: hw.deadline,
        onChangedCompletion: (completion) => changeCompletion(hw),
        onDelete: () => _removeHw(hw),
        onEdit: () => widget.editHw(hw.key),
      ),
    );
  }
}
