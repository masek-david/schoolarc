import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/bakalari/teacher_model.dart';
import 'package:school_manager/models/bakalari/timetable_change.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

class TimeTableLesson {
  TimeTableLesson({
    this.subject,
    this.change,
    this.teacher,
    this.room,
  });

  TimeTableLesson.empty();

  Subject? subject;
  BakaChange? change;
  String? room;
  Teacher? teacher;

  bool get isEmpty {
    return subject == null && change == null;
  }

  void showLessonDialog(BuildContext context, WidgetRef ref) {
    String? title = subject?.name;

    if (title == null) {
      if (change != null) {
        title = change!.name;
      }
    }
    if (title == null) {
      if (change?.description != null) {
        title = change!.description;
      }
    }

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
      ),
    );
  }
}
