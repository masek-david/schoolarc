import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/util/priority_model.dart';

class ExamTile extends StatelessWidget {
  const ExamTile({
    super.key,
    required this.text,
    required this.deadline,
    required this.subject,
    required this.priority,
    required this.completion,
    required this.onDelete,
    required this.onEdit,
  });

  final String subject;
  final String text;
  final DateTime deadline;
  final Priority priority;
  final bool completion;
  final Function(BuildContext)? onDelete;
  final Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    Color deadlineTextColor = Theme.of(context).colorScheme.onSurface;
    if (deadline.isBefore(DateTime.now())) {
      deadlineTextColor = Colors.red.harmonizeWith(Theme.of(context).primaryColor);
    }
    String deadlineText = '${deadline.day}.${deadline.month}.';
    if (deadline.year != DateTime.now().year) {
      deadlineText += ' ${deadline.year}';
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
    Color circleColor = priority.color;
    
    double opacity = 1;
    if(completion == true){
      opacity = 0.5;
    }

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
            color: Theme.of(context).colorScheme.primary.withAlpha(20),
          ),
          child: InkWell(
            onTap: onEdit,
            child: Opacity(
              opacity: opacity,
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
                            subject,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(width: 210, child: Text(text, maxLines: 2)),
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
                            style: TextStyle(color: deadlineTextColor, fontSize: 12),
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
      ),
    );
  }
}
