import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/screen_size.dart';
import 'package:school_manager/utils/task_functions.dart';
import 'package:school_manager/widgets/animated_completion.dart';
import 'package:school_manager/widgets/animated_star.dart';
import 'package:school_manager/widgets/expansion_title.dart';
import 'package:school_manager/widgets/wide_screen_app_bar.dart';

class AnimatedReorderableListItem {
  AnimatedReorderableListItem({this.hw, this.priority}) {
    assert(hw != null || priority != null);
  }

  HomeworkDTO? hw;
  TaskPriority? priority;

  int get getPriority {
    if (priority != null) {
      return priority!.index;
    }
    return hw!.priority.index;
  }

  @override
  String toString() {
    return '${hw != null ? hw.toString() : ''} ${priority != null ? priority!.index.toString() : ''}';
  }

  bool isSameAs(AnimatedReorderableListItem other) {
    if (priority != null && other.priority != null) {
      // print('${priority!.index}, hw:${hw?.dbIndex}; ${other.priority!.index}, hw:${other.hw?.dbIndex}, - same: ${priority!.index == other.priority!.index}');
      return priority!.index == other.priority!.index;
    }

    if (hw != null && other.hw != null) {
      return hw!.dbIndex == other.hw!.dbIndex;
    }

    return false;
  }
}

class HomeworksScreen extends ConsumerStatefulWidget {
  const HomeworksScreen({super.key});

  @override
  ConsumerState<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends ConsumerState<HomeworksScreen> {
  final Map<int, GlobalKey<AnimatedCompletionTileState>> _tileKeys = {};
  final Map<int, GlobalKey> _titleKeys = {};

  GlobalKey getTileKey(int id) {
    return _tileKeys.putIfAbsent(
        id, () => GlobalKey<AnimatedCompletionTileState>());
  }

  GlobalKey getTitleKey(int priority) {
    return _titleKeys.putIfAbsent(
        priority, () => GlobalKey<AnimatedCompletionTileState>());
  }

  @override
  Widget build(BuildContext context) {
    final hwByPriority = ref.watch(hwSortedProvider);
    final completedHws = ref.watch(hwCompletedProvider);

    final itemList = <AnimatedReorderableListItem>[];
    for (int i = 3; i >= 0; i--) {
      itemList.add(AnimatedReorderableListItem(priority: TaskPriority(i)));
      itemList.addAll(
          hwByPriority[i]!.map((e) => AnimatedReorderableListItem(hw: e)));
    }
    itemList.add(AnimatedReorderableListItem(priority: TaskPriority(-1)));
    final nonDraggableItems =
        itemList.where((element) => element.hw == null).toList();

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
              addNewHw(context, ref);
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
                child: itemList.length == 4
                    ? ListView(children: [AnimatedStar()])
                    : AnimatedReorderableListView(
                        items: itemList,
                        lockedItems: [
                          AnimatedReorderableListItem(priority: TaskPriority(3))
                        ],
                        nonDraggableItems: nonDraggableItems,
                        itemBuilder: (context, index) {
                          final item = itemList[index];

                          if (item.priority != null) {
                            if (item.priority!.index == -1) {
                              return Padding(
                                key: getTitleKey(-1),
                                padding: const EdgeInsets.only(bottom: 70),
                                child: ExpansionTile(
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
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: HomeworkTile(
                                          hw: hw,
                                          onChangedCompletion: (value) {
                                            ref
                                                .read(hwProvider.notifier)
                                                .complete(hw, value);
                                          },
                                          onDelete: () =>
                                              deleteHw(context, ref, hw),
                                          onEdit: () =>
                                              editHw(context, ref, hw),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                            return Padding(
                              key: getTitleKey(item.priority!.index),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: ExpansionTitle(
                                titleText: item.priority!.name,
                                titleTextColor: item.priority!.color,
                              ),
                            );
                          }

                          final hw = item.hw!;
                          return AnimatedCompletionTile(
                            key: getTileKey(hw.dbIndex),
                            hw: hw,
                            padding: EdgeInsets.symmetric(vertical: 4),
                            onChangedCompletion: (value) {
                              ref.read(hwProvider.notifier).complete(hw, value);
                            },
                            onDelete: () => deleteHw(context, ref, hw),
                            onEdit: () => editHw(context, ref, hw),
                          );
                        },

                        // removeItemBuilder: (child, animation) {
                        //   return AbsorbPointer(
                        //     child: AnimatedOpacity(
                        //       opacity: animation.value,
                        //       duration: Durations.extralong1,
                        //       child: child,
                        //     ),
                        //   );
                        // },
                        isSameItem: (a, b) => a.isSameAs(b),
                        onReorder: (oldIndex, newIndex) {
                          final item = itemList.removeAt(oldIndex);

                          final newPriority =
                              itemList[newIndex - 1].getPriority;
                          int newOrder = 0;
                          for (int i = 0; i < newIndex; i++) {
                            if (itemList[i].hw?.priority.index == newPriority) {
                              newOrder++;
                            }
                          }

                          if (item.hw != null) {
                            ref.read(hwProvider.notifier).reorder(
                                  item.hw!.order,
                                  newOrder,
                                  item.hw!.priority.index,
                                  newPriority,
                                  null,
                                  addTimestamp: true,
                                );
                          }
                        },
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
