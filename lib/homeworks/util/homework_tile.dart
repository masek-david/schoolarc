import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/homeworks/util/my_checkbox.dart';
import 'package:school_manager/util/priority_model.dart';

class HomeworkTile extends StatelessWidget {
  const HomeworkTile({
    super.key,
    required this.text,
    this.deadline,
    required this.subject,
    required this.completion,
    required this.priority,
    required this.onChangedCompletion,
    required this.onDelete,
    required this.onEdit,
  });

  final String subject;
  final String text;
  final DateTime? deadline;
  final bool completion;
  final Priority priority;
  final Function(bool?) onChangedCompletion;
  final Function() onDelete;
  final Function() onEdit;

  @override
  Widget build(BuildContext context) {
    Color deadlineColor = Theme.of(context).colorScheme.onSurface;
    String deadlineText = '';

    if (deadline != null) {
      if (deadline!.isBefore(DateTime.now()) && completion == false) {
        deadlineColor =
            Colors.red.harmonizeWith(Theme.of(context).primaryColor);
      }
      deadlineText = '${deadline!.day}.${deadline!.month}.';
      if (deadline!.year != DateTime.now().year) {
        deadlineText += ' ${deadline!.year}';
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
    if (completion == true) {
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
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.primary.withAlpha(20),
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
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Center(
                    child: Text(
                      subject,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: Text(text, maxLines: 2)),
                const SizedBox(width: 10),
                Text(
                  deadlineText,
                  maxLines: 2,
                  style: TextStyle(color: deadlineColor, fontSize: 12),
                ),
                MyCheckbox(
                  value: completion,
                  priority: priority,
                  onChanged: onChangedCompletion,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}