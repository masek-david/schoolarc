import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/util/get_priority_color.dart';

class ExamTile extends StatelessWidget {
  const ExamTile({
    super.key,
    required this.examText,
    required this.examDeadline,
    required this.examSubject,
    required this.examPriority,
    required this.onDelete,
    required this.onEdit,
  });

  final String examSubject;
  final String examText;
  final DateTime examDeadline;
  final int examPriority;
  final Function(BuildContext)? onDelete;
  final Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    Color deadlineColor = Theme.of(context).colorScheme.onSurface;
    if (examDeadline.isBefore(DateTime.now())) {
      deadlineColor = Colors.red.harmonizeWith(Theme.of(context).primaryColor);
    }
    String deadlineText = '${examDeadline.day}.${examDeadline.month}.';
    if (examDeadline.year != DateTime.now().year) {
      deadlineText += ' ${examDeadline.year}';
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
    Color circleColor =
        getPriorityColor(priority: examPriority, context: context);

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Slidable(
        groupTag: '0',
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: onDelete,
              icon: Icons.delete,
              foregroundColor: Theme.of(context).colorScheme.onError,
              backgroundColor: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(35),
              flex: 10,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: InkWell(
            onTap: onEdit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: circleColor.withAlpha(130),
                      ),
                      child: Center(
                        child: Text(
                          examSubject,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(width: 210, child: Text(examText, maxLines: 2)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 47,
                      child: Center(
                        child: Text(
                          deadlineText,
                          maxLines: 2,
                          style: TextStyle(color: deadlineColor, fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
