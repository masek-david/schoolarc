import 'package:animated_reorderable_list/animated_reorderable_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/features/tasks/task_functions.dart';
import 'package:schoolarc/m3e/expressive_loading/expressive_refresh_indicator.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/animated_shape.dart';
import 'package:schoolarc/widgets/lists/title_with_count.dart';
import 'package:schoolarc/widgets/snappable.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';
import 'package:schoolarc/widgets/web_request_focus.dart';

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

class HomeworksScreen extends ConsumerWidget {
  const HomeworksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hwByPriority = ref.watch(hwSortedProvider);
    final completedHws = ref.watch(hwCompletedProvider);

    final itemList = <_AnimatedReorderableListItem>[];
    for (int i = 3; i >= 0; i--) {
      itemList.add(_AnimatedReorderableListItem(priority: i));
      itemList.addAll(
        hwByPriority[i]!.map((e) => _AnimatedReorderableListItem(hw: e)),
      );
    }
    itemList.add(_AnimatedReorderableListItem(priority: -1));
    final nonDraggableItems = itemList
        .where((element) => element.hw == null)
        .toList();

    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: Scaffold(
        floatingActionButton: WebRequestFocusBuilder(
          builder: (showKeyboard) {
            return FloatingActionButton(
              tooltip: context.loc.addNewHomework,
              onPressed: () async {
                showKeyboard();
                vibrate.medium();
                addNewHw(context);
              },
              enableFeedback: true,
              child: const Icon(Icons.add_rounded),
            );
          },
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ExpressiveRefreshIndicator(
            enabled: ref.watch(firebaseLoginProvider).value == null
                ? false
                : true,
            onRefresh: () async {
              try {
                await ref.read(hwDataProvider.notifier).syncAll();
              } on Object catch (e) {
                if (context.mounted) {
                  showErrorMessage(context, e);
                }
                return;
              }
            },
            child: itemList.length == 5
                ? ListView(
                    children: [
                      const Snappable(child: AnimatedShape()),
                      _buildCompletedList(context, ref, completedHws),
                    ],
                  )
                : AnimatedReorderableListView(
                    padding: .only(
                      top:
                          MediaQuery.viewPaddingOf(context).top +
                          (context.isWide ? 0 : 64),
                    ),
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
                            completedHws,
                          );
                        }

                        final priority = TaskPriority(item.priority!);

                        return Padding(
                          key: ValueKey('hw title: ${item.priority!}'),
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

                      final hw = item.hw!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        key: ValueKey(
                          'hw: ${hw.id} ${hw.stateReaddingVersion}',
                        ),
                        child: HwTile(
                          // stateReaddingVersion needs to be here, it changes when the task is re-added, so it doesnt trigger
                          // Multiple widgets use the same globalkey error
                          hw: hw,
                          onChangedCompletion: (value) {
                            ref
                                .read(hwDataProvider.notifier)
                                .complete(hw.toData(), value);
                          },
                          onDelete: () => deleteHw(context, ref, hw),
                          onEdit: () => editHw(context, hw),
                          onConvert: () => convertHw(ref, hw),
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
                      if (item.hw == null) return;

                      final newPriority = itemList[newIndex - 1].getPriority;
                      int newOrder = 0;
                      for (int i = 0; i < newIndex; i++) {
                        if (itemList[i].hw?.priority.index == newPriority) {
                          newOrder++;
                        }
                      }

                      ref
                          .read(hwDataProvider.notifier)
                          .reorder(
                            item.hw!.toData(),
                            newOrder,
                            newPriority,
                          );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedList(
    BuildContext context,
    WidgetRef ref,
    List<Homework> completedHws,
  ) {
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
              padding: const EdgeInsets.only(bottom: 8),
              child: HwTile(
                hw: hw,
                onChangedCompletion: (value) {
                  ref
                      .read(hwDataProvider.notifier)
                      .complete(hw.toData(), value);
                },
                onDelete: () => deleteHw(context, ref, hw),
                onEdit: () => editHw(context, hw),
                onConvert: () => convertHw(ref, hw),
              ),
            );
          },
        ),
      ),
    );
  }
}
