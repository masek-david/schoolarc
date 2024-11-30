import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
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
    required this.onChangedCompletion,
    required this.onDelete,
    required this.onEdit,
  });

  final HomeworkDTO hw;
  final bool showDeadline;
  final SlidableController? slidableController;
  final Function(bool) onChangedCompletion;
  final Function() onDelete;
  final Function() onEdit;

  final double borderRadius = 12;
  final double padding = 5;

  @override
  Widget build(BuildContext context) {
    String deadlineText = '';
    final bool isMissed =
        hw.deadline.isBeforeToday() && hw.completion == false;
    final missedColor =
        Colors.red.harmonizeWith(Theme.of(context).primaryColor);

    if (showDeadline) {
      deadlineText = '${hw.deadline.day}.${hw.deadline.month}.';
      if (hw.deadline.year != DateTime.now().year) {
        deadlineText += ' ${hw.deadline.year}';
      } else if (deadlineText ==
          '${(DateTime.now().day) + 1}.${DateTime.now().month}.') {
        deadlineText = 'Tomorrow';
      } else if (deadlineText ==
          '${(DateTime.now().day)}.${DateTime.now().month}.') {
        deadlineText = 'Today';
      } else if (deadlineText ==
          '${(DateTime.now().day) - 1}.${DateTime.now().month}.') {
        deadlineText = 'Yesterday';
      }
    }

    double opacity = 1;
    if (hw.completion == true) {
      opacity = 0.5;
    }

    return Slidable(
      groupTag: '0',
      controller: slidableController,
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(),
            icon: Icons.delete,
            foregroundColor: Theme.of(context).colorScheme.onError,
            backgroundColor: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(borderRadius),
            flex: 10,
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: isMissed
              ? Border.all(
                  color: missedColor,
                  width: 2,
                )
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
          color: Theme.of(context).colorScheme.surfaceContainer,
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
                        borderRadius: BorderRadius.circular(borderRadius - padding),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: SubjectShortcut(subject: hw.subject),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(hw.text, maxLines: 2)),
                    const SizedBox(width: 5),
                    Text(
                      deadlineText,
                      maxLines: 2,
                      style: TextStyle(
                        color: isMissed ? missedColor : null,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 5),
                    MyCheckbox(
                      value: hw.completion,
                      priority: hw.priority,
                      onChanged: onChangedCompletion,
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
  }
}
