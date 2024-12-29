import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/animated_completion.dart';
import 'package:school_manager/widgets/animated_star.dart';
import 'package:school_manager/widgets/expansion_title.dart';
import 'package:school_manager/models/priority_model.dart';

class PriorityView extends StatelessWidget {
  const PriorityView({
    super.key,
    required this.hwByPriority,
    required this.completedHws,
    required this.reorderHomework,
    required this.updateView,
  });

  final Map<int, List<HomeworkDTO>> hwByPriority;
  final List<HomeworkDTO> completedHws;
  final Function(int oldPriority, int oldIndex, int newPriority, int newIndex)
      reorderHomework;
  final Function updateView;

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
    completedHws.sort(
      (a, b) {
        return b.timestamp.compareTo(a.timestamp);
      },
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new homework',
        onPressed: () {
          addTask(context, isHomework: true).then(
            (value) {
              updateView();
            },
          );
          HapticFeedback.lightImpact();
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
        child: RefreshIndicator(
          notificationPredicate:
              settings.get(Setting.useFirebase) ? (_) => true : (_) => false,
          onRefresh: () async {
            try {
              return await firestoreService.syncAll().then(
                (value) {
                  if (context.mounted) {
                    value.showSyncMessage(context);
                  }
                  updateView();
                },
              );
            } on Object catch (e) {
              if (context.mounted) {
                showMessage(context, e.toString(), isError: true);
              }
              return;
            }
          },
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
                  (index) => _buildList(TaskPriority(3 - index), context),
                ),
              ),
              ExpansionTile(
                title: ExpansionTitle(
                  numberOfItems: completedHws.length,
                  titleText: 'Completed',
                ),
                shape: const Border(),
                children: List.generate(
                  completedHws.length,
                  (index) {
                    HomeworkDTO hw = completedHws[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: HomeworkTile(
                        hw: hw,
                        onChangedCompletion: (value) async {
                          await changeCompletion(hw, value);
                          updateView();
                        },
                        onDelete: () =>
                            deleteHw(context, hw, () => updateView()).then(
                          (value) => updateView(),
                        ),
                        onTap: () => editHw(context, hw.dbIndex).then(
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
      ),
    );
  }

  _buildList(TaskPriority priority, BuildContext context) {
    var innerList = hwByPriority[priority.index];

    return DragAndDropListExpansion(
      listKey: ObjectKey(innerList),
      title: ExpansionTitle(
        titleText: priority.name,
        titleTextColor: priority.getColor(context),
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

  _buildItem(HomeworkDTO hw, BuildContext context) {
    return DragAndDropItem(
      child: AnimatedCompletionTile(
        hw: hw,
        onAnimationEnd: updateView,
        onChangedCompletion: (value) => changeCompletion(hw, value),
        onDelete: () => deleteHw(context, hw, () => updateView())
            .then((value) => updateView()),
        onEdit: () => editHw(context, hw.dbIndex).then((value) => updateView()),
      ),
    );
  }
}
