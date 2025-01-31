import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/screens/homeworks/widgets/my_checkbox.dart';
import 'package:school_manager/widgets/subject_shortcut.dart';

class HomeworkTile extends StatelessWidget {
  const HomeworkTile({
    super.key,
    required this.hw,
    this.showDeadline = true,
    this.slidableController,
    this.borderIfMissed = true,
    required this.onChangedCompletion,
    required this.onDelete,
    required this.onTap,
    this.showCompletion = true,
  });

  final HomeworkDTO hw;
  final bool showDeadline;
  final SlidableController? slidableController;
  final bool showCompletion;
  final bool borderIfMissed;
  final void Function(bool) onChangedCompletion;
  final void Function()? onDelete;
  final void Function() onTap;

  final double borderRadius = 12;
  final double padding = 5;

  @override
  Widget build(BuildContext context) {
    final bool isMissed =
        hw.deadline.isBeforeToday() && hw.isCompleted == false;
    final missedColor =
        Colors.red.harmonizeWith(Theme.of(context).primaryColor);

    double opacity = 1;
    if (hw.isCompleted && !hw.isBeingAnimated) {
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
          controller: slidableController,
          endActionPane: onDelete == null
              ? null
              : ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: extentRatio,
                  children: [
                    // https://github.com/letsar/flutter_slidable/issues/512#issuecomment-2540966428
                    // workaround for flutter_slidable
                    Theme(
                      data: Theme.of(context).copyWith(
                        outlinedButtonTheme: OutlinedButtonThemeData(
                          style: ButtonStyle(
                            iconColor: WidgetStatePropertyAll(
                                Theme.of(context).colorScheme.onError),
                          ),
                        ),
                      ),
                      child: SlidableAction(
                        onPressed: (context) {
                          HapticFeedback.lightImpact();
                          onDelete!();
                        },
                        icon: Icons.delete,
                        foregroundColor: Theme.of(context).colorScheme.onError,
                        backgroundColor: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(borderRadius),
                        flex: 10,
                      ),
                    ),
                  ],
                ),
          child: Container(
            decoration: BoxDecoration(
              border: isMissed && borderIfMissed
                  ? Border.all(
                      color: missedColor,
                      width: 2,
                    )
                  : null,
              borderRadius: BorderRadius.circular(borderRadius),
              color: hw.isCompleted && !hw.isBeingAnimated
                  ? Theme.of(context).colorScheme.surfaceContainerLowest
                  : Theme.of(context).colorScheme.surfaceContainerLow,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Opacity(
                  opacity: opacity,
                  // main row
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        if (settings.get(Setting.showDebugInfo))
                          Column(
                            children: [
                              Text('id: ${hw.dbIndex.toString()}'),
                              Text(hw.order.toString()),
                              if (hw.isBeingAnimated)
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
                          child: SubjectShortcut(subject: hw.subject),
                        ),
                        const SizedBox(width: 8),
                        if (hw.description != null && hw.description != '')
                          Icon(
                            Icons.notes,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        if (hw.description != null && hw.description != '')
                          const SizedBox(width: 8),
                        Expanded(child: Text(hw.text, maxLines: 2)),
                        const SizedBox(width: 5),
                        if (settings.get(Setting.showDebugInfo))
                          Text(hw.timestamp.millisecondsSinceEpoch.toString()),
                        if (showDeadline)
                          Text(
                            hw.deadline.dateText(),
                            maxLines: 2,
                            style: TextStyle(
                              color: isMissed ? missedColor : null,
                              fontSize: 12,
                            ),
                          ),
                        const SizedBox(width: 4),
                        if (showCompletion)
                          MyCheckbox(
                            value: hw.isCompleted,
                            priority: hw.priority,
                            onChanged: onChangedCompletion,
                            // must be here
                            key: ValueKey('checkbox ${hw.dbIndex}'),
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
