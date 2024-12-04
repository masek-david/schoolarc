import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/widgets/subject_shortcut.dart';

class ExamTile extends StatelessWidget {
  const ExamTile({
    super.key,
    required this.exam,
    this.showDeadline = true,
    required this.onDelete,
    required this.onEdit,
  });

  final ExamDTO exam;
  final bool showDeadline;
  final Function(BuildContext) onDelete;
  final Function() onEdit;

  @override
  Widget build(BuildContext context) {
    final bool isMissed = exam.deadline.isBeforeToday();

    Color missedColor =
        Colors.red.harmonizeWith(Theme.of(context).primaryColor);

    double opacity = 1;
    if (exam.completion == true) {
      opacity = 0.5;
    }

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(1000)),
      child: Slidable(
        groupTag: '0',
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.lightImpact();
                onDelete(context);
              },
              icon: Icons.delete,
              foregroundColor: Theme.of(context).colorScheme.onError,
              backgroundColor: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(35),
              flex: 10,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(35),
              child: Opacity(
                opacity: opacity,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: exam.priority.getContainerColor(context)
                        ),
                        child: SubjectShortcut(
                          subject: exam.subject,
                          color: exam.priority.getOnContainerColor(context)
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(exam.text, maxLines: 2)),
                      const SizedBox(width: 10),
                      if (showDeadline)
                        Text(
                          exam.deadline.dateText(),
                          maxLines: 2,
                          style: TextStyle(
                              color: isMissed ? missedColor : null,
                              fontSize: 12),
                        ),
                      const SizedBox(width: 10),
                      if (exam.description != null && exam.description != '')
                        Icon(
                          Icons.notes,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
