import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/widgets/tile/hw_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/screen_size.dart';
import 'package:school_manager/utils/task_functions.dart';
import 'package:school_manager/widgets/animated_shape.dart';
import 'package:school_manager/widgets/expansion_title.dart';
import 'package:school_manager/widgets/wide_screen_app_bar.dart';

class _AnimatedReorderableListItem {
  _AnimatedReorderableListItem({this.hw, this.priority}) {
    assert(hw != null || priority != null);
  }

  Homework? hw;
  int? priority;

  int get getPriority {
    if (priority != null) {
      return priority!;
    }
    return hw!.priority.index;
  }

  @override
  String toString() {
    return '${hw != null ? hw.toString() : ''} ${priority != null ? priority!.toString() : ''}';
  }

  bool isSameAs(_AnimatedReorderableListItem other) {
    if (priority != null && other.priority != null) {
      return priority! == other.priority!;
    }

    if (hw != null && other.hw != null) {
      return hw!.id == other.hw!.id;
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
  bool showingCompleted = false;

  @override
  Widget build(BuildContext context) {
    final hwByPriority = ref.watch(hwSortedProvider);
    final completedHws = ref.watch(hwCompletedProvider);

    final itemList = <_AnimatedReorderableListItem>[];
    for (int i = 3; i >= 0; i--) {
      itemList.add(_AnimatedReorderableListItem(priority: i));
      itemList.addAll(
          hwByPriority[i]!.map((e) => _AnimatedReorderableListItem(hw: e)));
    }
    itemList.add(_AnimatedReorderableListItem(priority: -1));
    final nonDraggableItems =
        itemList.where((element) => element.hw == null).toList();

    if (showingCompleted) {
      itemList.add(_AnimatedReorderableListItem(priority: 10));
    }

    return ValueListenableBuilder(
      valueListenable: ScreenSize.isWideScreen,
      builder: (context, isWide, child) {
        return MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Scaffold(
            appBar: WideScreenAppBar(
              isWideScreen: isWide,
              title: Text(context.loc.homeworks(2)),
            ),
            floatingActionButton: FloatingActionButton(
              tooltip: context.loc.addNewHomework,
              onPressed: () async {
                HapticFeedback.mediumImpact();
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
                          const AnimatedShape(),
                          _buildCompletedList(context, ref, completedHws),
                        ])
                      : AnimatedReorderableListView(
                          items: itemList,
                          buildDefaultDragHandles: false,
                          lockedItems: [
                            _AnimatedReorderableListItem(priority: 3),
                            _AnimatedReorderableListItem(priority: -1),
                          ],
                          nonDraggableItems: nonDraggableItems,
                          onReorderStart: (p0) => HapticFeedback.mediumImpact(),
                          itemBuilder: (context, index) {
                            final item = itemList[index];

                            if (item.priority != null) {
                              if (item.priority! == -1) {
                                return _buildCompletedList(
                                    context, ref, completedHws);
                              }

                              final priority = TaskPriority(item.priority!);

                              return Padding(
                                key: ValueKey('hw title: ${item.priority!}'),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: TitleWithCount(
                                  text: priority.name,
                                  textColor: priority.getColor(context),
                                ),
                              );
                            }

                            final hw = item.hw!;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              key: ValueKey(
                                  'hw: ${hw.id} ${hw.stateReaddingVersion}'),
                              child: HwTile(
                                // stateReaddingVersion needs to be here, it changes when the task is re-added, so it doesnt trigger
                                // Multiple widgets use the same globalkey error
                                hw: hw,
                                onChangedCompletion: (value) {
                                  ref
                                      .read(hwProvider.notifier)
                                      .complete(hw, value);
                                },
                                onDelete: () => deleteHw(context, ref, hw),
                                onEdit: () => editHw(context, ref, hw),
                                onConvert: () => convertHw(context, ref, hw),
                              ),
                            );
                          },
                          removeItemBuilder: (child, animation) {
                            // we need custom remove item painter, to absorb pointer, the user mustnt
                            // add it back when its already animating, it could trigger Multiple widgets use the same globalkey error

                            return FadeTransition(
                              opacity: animation,
                              child: AbsorbPointer(child: child),
                            );
                          },
                          isSameItem: (a, b) => a.isSameAs(b),
                          onReorder: (oldIndex, newIndex) {
                            final item = itemList.removeAt(oldIndex);

                            final newPriority =
                                itemList[newIndex - 1].getPriority;
                            int newOrder = 0;
                            for (int i = 0; i < newIndex; i++) {
                              if (itemList[i].hw?.priority.index ==
                                  newPriority) {
                                newOrder++;
                              }
                            }

                            if (item.hw != null) {
                              ref.read(hwProvider.notifier).reorder(
                                    newOrder,
                                    newPriority,
                                    item.hw!,
                                    addTimestamp: true,
                                  );
                            }
                          },
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletedList(
      BuildContext context, WidgetRef ref, List<Homework> completedHws) {
    // return SettingTile.withSwitch(
    //   key: const ValueKey('some key'),
    //   title: 'show',
    //   value: showingCompleted,
    //   onChanged: (value) => setState(() {
    //     showingCompleted = value;
    //   }),
    // );

    return Padding(
      key: const ValueKey('hw completed title'),
      padding: const EdgeInsets.only(bottom: 70),
      child: ExpansionTile(
        title: TitleWithCount(
          count: completedHws.length,
          text: context.loc.completed,
        ),
        shape: const Border(),
        children: List.generate(
          completedHws.length,
          (index) {
            final hw = completedHws[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: HwTile(
                hw: hw,
                onChangedCompletion: (value) {
                  ref.read(hwProvider.notifier).complete(hw, value);
                },
                onDelete: () => deleteHw(context, ref, hw),
                onEdit: () => editHw(context, ref, hw),
                onConvert: () => convertHw(context, ref, hw),
              ),
            );
          },
        ),
      ),
    );
  }
}
