import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/bakalari/teacher_model.dart';
import 'package:schoolarc/models/bakalari/timetable_change.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class TimeTableLesson {
  TimeTableLesson({
    this.subject,
    this.change,
    this.teacher,
    this.room,
  });

  TimeTableLesson.empty()
      : subject = null,
        change = null,
        room = null,
        teacher = null;

  final Subject? subject;
  final BakaChange? change;
  final String? room;
  final Teacher? teacher;

  bool get isEmpty {
    return subject == null && change == null;
  }

  TimeTableLesson copyWith({
    Object? subject = noChange,
    Object? change = noChange,
    Object? teacher = noChange,
    Object? room = noChange,
  }) {
    return TimeTableLesson(
      subject: subject == noChange ? this.subject : subject as Subject?,
      change: change == noChange ? this.change : change as BakaChange?,
      teacher: teacher == noChange ? this.teacher : teacher as Teacher?,
      room: room == noChange ? this.room : room as String?,
    );
  }

  void showLessonDialog(BuildContext context, WidgetRef ref,
      {void Function()? onSubjectAdded}) {
    String? title = subject?.name;

    title ??= context.loc.emptyLesson;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title!),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subject?.id == '')
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  spacing: 12,
                  children: [
                    Container(
                      height: 8,
                      width: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.blue.harmonizeWith(
                          Theme.of(context).colorScheme.surfaceContainer,
                        ),
                      ),
                    ),
                    Flexible(
                      child: Text(context.loc.subjectHasntBeenAdded),
                    ),
                    FilledButton(
                      onPressed: () async {
                        await ref.read(subjectsProvider.notifier).saveNew(
                              subject!.convert(),
                            );
                        if (onSubjectAdded != null) {
                          onSubjectAdded();
                        }
                        if (context.mounted) {
                          showMessage(context, context.loc.importedSubject);
                        }
                      },
                      child: Text(context.loc.add),
                    ),
                  ],
                ),
              ),
            if (change != null)
              Text('${context.loc.change}: ${change?.description}'),
            if (teacher != null)
              Text('${context.loc.teacher}: ${teacher?.name}'),
            if (room != null) Text('${context.loc.room}: $room'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.loc.close),
          ),
        ],
      ),
    );
  }
}
