import 'package:flutter/material.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/subject_shortcut.dart';
import 'package:schoolarc/widgets/tiles/tile_slidable.dart';

class ExamTile extends StatelessWidget {
  const ExamTile({
    super.key,
    required this.exam,
    this.showDeadline = true,
    required this.onDelete,
    required this.onEdit,
    required this.onConvert,
  });

  final Exam exam;
  final bool showDeadline;
  final void Function()? onDelete;
  final void Function() onEdit;
  final void Function()? onConvert;

  @override
  Widget build(BuildContext context) {
    double opacity = 1;
    if (exam.isCompleted == true) {
      opacity = 0.5;
    }

    return LayoutBuilder(builder: (context, constraints) {
      double extentRatio = 135 / constraints.maxWidth;

      if (extentRatio > 1) {
        extentRatio = 1;
      }

      return ClipRect(
        child: TileSlidable(
          isHomework: false,
          borderRadius: 100,
          onDelete: onDelete,
          onConvert: onConvert,
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
                        if (settings.get(Setting.debugMode))
                          Text(exam.order.toString()),
                        AnimatedContainer(
                          width: 50,
                          height: 50,
                          duration: const Duration(milliseconds: 300),
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
                        const SizedBox(width: 8),
                        if (showDeadline)
                          Text(
                            exam.deadline.dateText(),
                            maxLines: 2,
                            style: const TextStyle(fontSize: 12),
                          ),
                        const SizedBox(width: 8),
                      ],
                    ),
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
