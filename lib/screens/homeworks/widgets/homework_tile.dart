import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/screens/homeworks/widgets/hw_overlay.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/screens/homeworks/widgets/my_checkbox.dart';
import 'package:school_manager/widgets/subject_shortcut.dart';

class HomeworkTile extends StatefulWidget {
  const HomeworkTile({
    super.key,
    required this.hw,
    this.showDeadline = true,
    this.slidableController,
    this.borderIfMissed = true,
    required this.onChangedCompletion,
    required this.onDelete,
    required this.onEdit,
    this.showCompletion = true,
    required this.onConvert,
  });

  final HomeworkDTO hw;
  final bool showDeadline;
  final SlidableController? slidableController;
  final bool showCompletion;
  final bool borderIfMissed;
  final void Function(bool) onChangedCompletion;
  final void Function()? onDelete;
  final void Function() onEdit;
  final void Function()? onConvert;

  @override
  State<HomeworkTile> createState() => _HomeworkTileState();
}

class _HomeworkTileState extends State<HomeworkTile> {
  static const double borderRadius = 12;
  static const double padding = 5;

  final widgetKey = GlobalKey();
  bool isShown = true;
  bool expUseHwOverlay = settings.get(Setting.expUseHwOverlay);

  @override
  Widget build(BuildContext context) {
    if (!isShown) {
      return SizedBox(height: 60);
    }

    final bool isMissed =
        widget.hw.deadline.isBeforeToday() && widget.hw.isCompleted == false;
    final missedColor =
        Colors.red.harmonizeWith(Theme.of(context).primaryColor);

    double opacity = 1;
    if (widget.hw.isCompleted && !widget.hw.isBeingAnimated) {
      opacity = 0.5;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        double extentRatio = 120 / constraints.maxWidth;

        if (extentRatio > 1) {
          extentRatio = 1;
        }

        return Slidable(
          groupTag: '0',
          enabled: !expUseHwOverlay,
          controller: widget.slidableController,
          startActionPane: widget.onConvert == null
              ? null
              : ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: extentRatio,
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        HapticFeedback.lightImpact();
                        widget.onConvert!();
                      },
                      icon: Icons.swap_vertical_circle_outlined,
                      label: 'To exam',
                      foregroundColor:
                          Theme.of(context).colorScheme.onTertiaryContainer,
                      backgroundColor:
                          Theme.of(context).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(borderRadius),
                      flex: 10,
                    ),
                  ],
                ),
          endActionPane: widget.onDelete == null
              ? null
              : ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: extentRatio,
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        HapticFeedback.lightImpact();
                        widget.onDelete!();
                      },
                      icon: Icons.delete,
                      foregroundColor:
                          Theme.of(context).colorScheme.onErrorContainer,
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(borderRadius),
                      flex: 10,
                    ),
                  ],
                ),
          child: AnimatedContainer(
            key: widgetKey,
            duration: Duration(milliseconds: 200),
            decoration: BoxDecoration(
              border: isMissed && widget.borderIfMissed
                  ? Border.all(
                      color: missedColor,
                      width: 2,
                    )
                  : null,
              borderRadius: BorderRadius.circular(borderRadius),
              color: widget.hw.isCompleted && !widget.hw.isBeingAnimated
                  ? Theme.of(context).colorScheme.surfaceContainerLowest
                  : Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: expUseHwOverlay
                  ? () {
                      final RenderBox renderBox = widgetKey.currentContext!
                          .findRenderObject() as RenderBox;
                      final Offset position = renderBox
                          .localToGlobal(Offset.zero); // Get global position
                      final Size size = renderBox.size; // Get widget size

                      late final OverlayEntry overlay;
                      overlay = OverlayEntry(
                        builder: (context) {
                          return HwOverlay(
                            hw: widget.hw,
                            position: position,
                            size: size,
                            onEdit: widget.onEdit,
                            onDelete: widget.onDelete,
                            onHide: () {
                              overlay.remove();
                              setState(() {
                                isShown = true;
                              });
                            },
                          );
                        },
                      );

                      Overlay.of(context).insert(overlay);
                      setState(() {
                        isShown = false;
                      });
                    }
                  : widget.onEdit,
              child: Material(
                color: Colors.transparent,
                child: Opacity(
                  opacity: opacity,
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    // main row
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (settings.get(Setting.showDebugInfo))
                          Column(
                            children: [
                              Text('id: ${widget.hw.dbIndex.toString()}'),
                              Text(widget.hw.order.toString()),
                              if (widget.hw.isBeingAnimated)
                                Icon(
                                  Icons.animation,
                                  size: 10,
                                )
                            ],
                          ),
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(borderRadius - padding),
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                          ),
                          child: SubjectShortcut(subject: widget.hw.subject),
                        ),
                        const SizedBox(width: 8),
                        if (widget.hw.description != null &&
                            widget.hw.description != '')
                          Icon(
                            Icons.notes,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        if (widget.hw.description != null &&
                            widget.hw.description != '')
                          const SizedBox(width: 8),
                        Expanded(child: Text(widget.hw.text, maxLines: 2)),
                        const SizedBox(width: 5),
                        if (settings.get(Setting.showDebugInfo))
                          Column(
                            children: [
                              Text(
                                widget.hw.fireId ?? 'no fireId',
                                style: TextStyle(fontSize: 8),
                              ),
                              Text(widget.hw.timestamp.millisecondsSinceEpoch
                                  .toString()),
                            ],
                          ),
                        if (widget.showDeadline)
                          Text(
                            widget.hw.deadline.dateText(),
                            maxLines: 2,
                            style: TextStyle(
                              color: isMissed ? missedColor : null,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(width: 4),
                        if (widget.showCompletion)
                          MyCheckbox(
                            value: widget.hw.isCompleted,
                            priority: widget.hw.priority,
                            onChanged: widget.onChangedCompletion,
                            // must be here
                            key: ValueKey('checkbox ${widget.hw.dbIndex}'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
