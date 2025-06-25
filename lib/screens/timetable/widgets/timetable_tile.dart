import 'package:flutter/material.dart';
import 'package:school_manager/models/bakalari/timetable_change.dart';
import 'package:school_manager/models/bakalari/timetable_lesson_model.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/subject_shortcut.dart';

class TimetableTile extends StatelessWidget {
  const TimetableTile({
    super.key,
    required this.lesson,
    required this.columnWidth,
    required this.onTap,
    this.isHighlighted = false,
  });

  final TimeTableLesson? lesson;
  final double columnWidth;
  final bool isHighlighted;
  final void Function(TimeTableLesson? lesson)? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color tileColor = isHighlighted
        ? colorScheme.tertiaryContainer
        : colorScheme.surfaceContainer;
    final change = lesson?.change;
    if (change != null) {
      tileColor = Theme.of(context).colorScheme.errorContainer;
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: columnWidth,
          height: double.infinity,
          decoration: BoxDecoration(
            border: lesson?.subject == null
                ? Border.all(
                    color: tileColor,
                    width: 2,
                  )
                : null,
            color: lesson?.subject == null ? null : tileColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (onTap != null) {
                  onTap!(lesson);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (lesson?.subject?.isFromBakalari == true &&
                        settings.get(Setting.showDebugInfo))
                      Text('baka: ${lesson?.subject?.bakaId}'),
                    const Spacer(),
                    if (lesson?.change?.type == ChangeType.canceled)
                      Text(lesson?.change?.shortcut ?? ''),
                    if (lesson?.subject != null)
                      SubjectShortcut(
                        subject: lesson?.subject,
                        color: change != null ? Theme.of(context).colorScheme.onErrorContainer : null,
                      ),
                    const Spacer(),
                    if (lesson?.teacher != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(lesson?.teacher?.shortcut ?? ''),
                          Text(lesson?.room ?? ''),
                        ],
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
