import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/task_model.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/screen_size.dart';
import 'package:school_manager/widgets/add_bottom_sheet/add_bottom_sheet%20_new.dart';
import 'package:school_manager/widgets/animated_completion.dart';
import 'package:school_manager/widgets/animated_star.dart';
import 'package:school_manager/widgets/expansion_title.dart';
import 'package:school_manager/widgets/list_bottom_spacer.dart';
import 'package:school_manager/widgets/wide_screen_app_bar.dart';

class HomeworksScreen extends ConsumerStatefulWidget {
  const HomeworksScreen({super.key});

  @override
  ConsumerState<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends ConsumerState<HomeworksScreen> {
  final Map<int, GlobalKey<AnimatedCompletionTileState>> _tileKeys = {};

  GlobalKey getTileKey(int id) {
    return _tileKeys.putIfAbsent(
        id, () => GlobalKey<AnimatedCompletionTileState>());
  }

  void delete(HomeworkDTO hw, WidgetRef ref) {
    ref.read(hwProvider.notifier).delete(hw);

    showMessage(context, 'Deleted homework ${hw.text}', actions: [
      SnackBarAction(
        label: 'Undo',
        onPressed: () {
          ref.read(hwProvider.notifier).revertDelete(hw);
        },
      ),
    ]);
  }

  void edit(HomeworkDTO hw, WidgetRef ref) async {
    HomeworkDTO? edited = await showModalBottomSheet<HomeworkDTO>(
      context: context,
      builder: (context) => AddTaskBottomSheetNEW(
        initialTask: hw,
        autoSetDate: false,
      ),
    );

    if (edited != null) {
      ref.read(hwProvider.notifier).edit(edited);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hwByPriority = ref.watch(hwSortedProvider);
    final completedHws = ref.watch(hwCompletedProvider);

    int numberOfPriorityLists = 0;
    hwByPriority.forEach(
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
            title: const Text('Homeworks'),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Add new homework',
            onPressed: () async {
              HapticFeedback.lightImpact();
              final newHw = await showModalBottomSheet<Task?>(
                context: context,
                builder: (context) => AddTaskBottomSheetNEW(
                  initialTask: Task.empty(),
                  autoSetDate: true,
                ),
              );

              if (newHw != null) {
                ref.read(hwProvider.notifier).saveNew(newHw.toHw());
              }
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
                    await ref.read(hwProvider.notifier).syncAll();
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
                        ref.read(hwProvider.notifier).reorder(
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
                          hwByPriority[3 - index]!,
                          TaskPriority(3 - index),
                          context,
                          ref,
                        ),
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
                              onChangedCompletion: (value) {
                                ref
                                    .read(hwProvider.notifier)
                                    .complete(hw, value);
                              },
                              onDelete: () => delete(hw, ref),
                              onTap: () => edit(hw, ref),
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

  DragAndDropListExpansion _buildList(List<HomeworkDTO> list,
      TaskPriority priority, BuildContext context, WidgetRef ref) {
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
      HomeworkDTO hw, BuildContext context, WidgetRef ref) {
    return DragAndDropItem(
      feedbackWidget: AnimatedCompletionTile(
        hw: hw,
        onAnimationEnd: () {},
        onChangedCompletion: (value) {
          ref.read(hwProvider.notifier).complete(hw, value);
        },
        onDelete: () => delete(hw, ref),
        onEdit: () => edit(hw, ref),
      ),
      child: AnimatedCompletionTile(
        hw: hw,
        key: getTileKey(hw.dbIndex),
        onAnimationEnd: () {},
        onChangedCompletion: (value) {
          ref.read(hwProvider.notifier).complete(hw, value);
        },
        onDelete: () => delete(hw, ref),
        onEdit: () => edit(hw, ref),
      ),
    );
  }
}
