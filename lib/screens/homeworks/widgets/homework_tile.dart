import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/screens/homeworks/widgets/my_checkbox.dart';
import 'package:school_manager/data/priority_model.dart';

class HomeworkTile extends StatelessWidget {
  const HomeworkTile({
    super.key,
    required this.hw,
    this.showDeadline = true,
    required this.priority,
    required this.onChangedCompletion,
    required this.onDelete,
    required this.onEdit,
  });

  final HomeworkDTO hw;
  final Priority priority;
  final bool showDeadline;
  final Function(bool) onChangedCompletion;
  final Function() onDelete;
  final Function() onEdit;

  final double borderRadius = 12;
  final double padding = 5;

  @override
  Widget build(BuildContext context) {
    Color deadlineColor = Theme.of(context).colorScheme.onSurface;
    String deadlineText = '';

    if (showDeadline) {
      if (hw.deadline.isBefore(DateTime.now()) && hw.completion == false) {
        deadlineColor =
            Colors.red.harmonizeWith(Theme.of(context).primaryColor);
      }
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
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.3,
        children: [
          SlidableAction(
            onPressed: (context) => onDelete(),
            icon: Icons.delete,
            foregroundColor: Theme.of(context).colorScheme.onError,
            backgroundColor: Theme.of(context).colorScheme.error,
            borderRadius: BorderRadius.circular(10),
            flex: 10,
          ),
        ],
      ),
      child: InkWell(
        onTap: onEdit,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            color:
                Theme.of(context).colorScheme.secondaryContainer.withAlpha(100),
          ),
          child: Opacity(
            opacity: opacity,
            // main row
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
                  child: Center(
                    child: Text(
                      hw.subject?.shortcut ?? '',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(hw.text, maxLines: 2)),
                const SizedBox(width: 5),
                Text(
                  deadlineText,
                  maxLines: 2,
                  style: TextStyle(color: deadlineColor, fontSize: 12),
                ),
                const SizedBox(width: 5),
                MyCheckbox(
                  value: hw.completion,
                  priority: priority,
                  onChanged: onChangedCompletion,
                  key: ValueKey('checkbox ${hw.dbIndex}'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
