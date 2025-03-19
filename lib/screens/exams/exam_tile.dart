import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/widgets/subject_shortcut.dart';

class ExamTile extends StatelessWidget {
  const ExamTile({
    super.key,
    required this.exam,
    this.showDeadline = true,
    required this.onDelete,
    required this.onEdit,
    required this.onConvert,
  });

  final ExamDTO exam;
  final bool showDeadline;
  final void Function()? onDelete;
  final void Function() onEdit;
  final void Function()? onConvert;

  @override
  Widget build(BuildContext context) {
    final bool isMissed = exam.deadline.isBeforeToday();

    Color missedColor =
        Colors.red.harmonizeWith(Theme.of(context).primaryColor);

    double opacity = 1;
    if (exam.isCompleted == true) {
      opacity = 0.5;
    }

    return LayoutBuilder(builder: (context, constraints) {
      double extentRatio = 135 / constraints.maxWidth;

      if (extentRatio > 1) {
        extentRatio = 1;
      }

      return Slidable(
        groupTag: '0',
        startActionPane: onConvert == null
            ? null
            : ActionPane(
                motion: const StretchMotion(),
                extentRatio: extentRatio,
                children: [
                  SlidableAction(
                    onPressed: (context) {
                      HapticFeedback.lightImpact();
                      onConvert!();
                    },
                    icon: Icons.swap_vertical_circle_outlined,
                    label: 'To homework',
                    foregroundColor:
                        Theme.of(context).colorScheme.onTertiaryContainer,
                    backgroundColor:
                        Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(100),
                    flex: 10,
                  ),
                ],
              ),
        endActionPane: onDelete == null ? null : ActionPane(
          motion: const StretchMotion(),
          extentRatio: extentRatio,
          children: [
              SlidableAction(
                onPressed: (context) {
                  HapticFeedback.lightImpact();
                  onDelete!();
                },
                icon: Icons.delete,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(35),
                flex: 10,
              ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            color: exam.isCompleted
                ? Theme.of(context).colorScheme.surfaceContainerLowest
                : Theme.of(context).colorScheme.surfaceContainerLow,
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
                      if (settings.get(Setting.showDebugInfo))
                        Column(
                          children: [
                            Text('id: ${exam.dbIndex.toString()}'),
                            Text(exam.order.toString()),
                          ],
                        ),
                      AnimatedContainer(
                        width: 50,
                        height: 50,
                        duration: Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: exam.priority.getContainerColor(context)),
                        child: SubjectShortcut(
                            subject: exam.subject,
                            color: exam.priority.getOnContainerColor(context)),
                      ),
                      if (exam.description != null && exam.description != '')
                        const SizedBox(width: 8),
                      if (exam.description != null && exam.description != '')
                        Icon(
                          Icons.notes,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(exam.text, maxLines: 2)),
                      if (settings.get(Setting.showDebugInfo))
                        Column(
                          children: [
                            Text(
                                'ts: ${exam.timestamp.millisecondsSinceEpoch}'),
                          ],
                        ),
                      const SizedBox(width: 8),
                      if (showDeadline)
                        Text(
                          exam.deadline.dateText(),
                          maxLines: 2,
                          style: TextStyle(
                              color: isMissed ? missedColor : null,
                              fontSize: 12),
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
