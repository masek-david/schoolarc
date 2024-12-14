import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
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
    required this.onEdit,
    this.showCompletion = true,
  });

  final HomeworkDTO hw;
  final bool showDeadline;
  final SlidableController? slidableController;
  final bool showCompletion;
  final bool borderIfMissed;
  final Function(bool) onChangedCompletion;
  final Function() onDelete;
  final Function() onEdit;

  final double borderRadius = 12;
  final double padding = 5;

  @override
  Widget build(BuildContext context) {
    final bool isMissed = hw.deadline.isBeforeToday() && hw.completion == false;
    final missedColor =
        Colors.red.harmonizeWith(Theme.of(context).primaryColor);

    double opacity = 1;
    if (hw.completion == true) {
      opacity = 0.5;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Slidable(
          groupTag: '0',
          controller: slidableController,
          endActionPane: ActionPane(
            motion: const StretchMotion(),
            extentRatio: 120 / constraints.maxWidth,
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
                    onDelete();
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
              color: hw.completion
                  ? Theme.of(context).colorScheme.surfaceContainerLowest
                  : Theme.of(context).colorScheme.surfaceContainer,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEdit,
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
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(borderRadius - padding),
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
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
                            value: hw.completion,
                            priority: hw.priority,
                            onChanged: onChangedCompletion,
                            // must be heres
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
