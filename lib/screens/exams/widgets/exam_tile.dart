import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/utils/extensions/color_extension.dart';
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
    Color deadlineTextColor = Theme.of(context).colorScheme.onSurface;
    String deadlineText = '';
    Color circleColor = exam.priority.color;

    if (showDeadline) {
      if (exam.deadline.isBefore(DateTime.now())) {
        deadlineTextColor =
            Colors.red.harmonizeWith(Theme.of(context).primaryColor);
      }
      deadlineText = '${exam.deadline.day}.${exam.deadline.month}.';
      if (exam.deadline.year != DateTime.now().year) {
        deadlineText += ' ${exam.deadline.year}';
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
                          color: circleColor.dynamicLighten(
                            makeItLighter:
                                Theme.of(context).brightness != Brightness.dark,
                            amount: 0.1,
                          ),
                        ),
                        child: SubjectShortcut(
                          subject: exam.subject,
                          color: circleColor.dynamicLighten(
                            makeItLighter:
                                Theme.of(context).brightness == Brightness.dark,
                            amount: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: Text(exam.text, maxLines: 2)),
                      const SizedBox(width: 10),
                      Text(
                        deadlineText,
                        maxLines: 2,
                        style: TextStyle(color: deadlineTextColor, fontSize: 12),
                      ),
                      const SizedBox(width: 10),
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
