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

class _AnimatedReorderableListItem {
  _AnimatedReorderableListItem({this.hw, this.priority}) {
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

  bool isSameAs(_AnimatedReorderableListItem other) {
    if (priority != null && other.priority != null) {
      return priority!.index == other.priority!.index;
    }

    if (hw != null && other.hw != null) {
      return hw!.dbIndex == other.hw!.dbIndex;
    }

    return false;
  }
}

class HomeworksScreen extends ConsumerWidget {
  const HomeworksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hwByPriority = ref.watch(hwSortedProvider);
    final completedHws = ref.watch(hwCompletedProvider);

    final itemList = <_AnimatedReorderableListItem>[];
    for (int i = 3; i >= 0; i--) {
      itemList.add(_AnimatedReorderableListItem(priority: TaskPriority(i)));
      itemList.addAll(
          hwByPriority[i]!.map((e) => _AnimatedReorderableListItem(hw: e)));
    }
    itemList.add(_AnimatedReorderableListItem(priority: TaskPriority(-1)));
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
                child: itemList.length == 5
                    ? ListView(children: [
                        AnimatedStar(),
                        _buildCompletedList(context, ref, completedHws),
                      ])
                    : AnimatedReorderableListView(
                        items: itemList,
                        lockedItems: [
                          _AnimatedReorderableListItem(
                              priority: TaskPriority(3))
                        ],
                        nonDraggableItems: nonDraggableItems,
                        itemBuilder: (context, index) {
                          final item = itemList[index];

                          if (item.priority != null) {
                            if (item.priority!.index == -1) {
                              return _buildCompletedList(
                                  context, ref, completedHws);
                            }
                            return Padding(
                              key:
                                  ValueKey('hw title: ${item.priority!.index}'),
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
                            // timestamp needs to be there, when the animation plays (on leave) and it should appear,
                            // you would get multiple widgets used the same global key error
                            key: ValueKey('hw: ${hw.dbIndex} ${hw.timestamp}'),
                            hw: hw,
                            padding: EdgeInsets.symmetric(vertical: 4),
                            onChangedCompletion: (value) {
                              ref.read(hwProvider.notifier).complete(hw, value);
                            },
                            onDelete: () => deleteHw(context, ref, hw),
                            onEdit: () => editHw(context, ref, hw),
                          );
                        },
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

  Widget _buildCompletedList(
      BuildContext context, WidgetRef ref, List<HomeworkDTO> completedHws) {
    return Padding(
      key: ValueKey('hw completed title'),
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
            final hw = completedHws[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: HomeworkTile(
                hw: hw,
                onChangedCompletion: (value) {
                  ref.read(hwProvider.notifier).complete(hw, value);
                },
                onDelete: () => deleteHw(context, ref, hw),
                onEdit: () => editHw(context, ref, hw),
              ),
            );
          },
        ),
      ),
    );
  }
}
