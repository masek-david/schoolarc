import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
import 'package:schoolarc/features/timetable/domain/lesson_model.dart';
import 'package:schoolarc/features/timetable/domain/period_model.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';

void showLessonDialog({
  required final BuildContext context,
  required final WidgetRef ref,
  required final Lesson lesson,
  Period? period,
}) {
  String? title = lesson.subject?.name;

  title ??= context.loc.emptyLesson;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title!),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (period != null)
            Text(
              period.toStringFormatted(context),
              style: context.txt.labelLarge,
            ),
          if (lesson.subject?.id == '')
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 0, 8),
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
                  M3EFilledButton.icon(
                    onPressed: () async {
                      await ref
                          .read(subjectsProvider.notifier)
                          .create(lesson.subject!.convert());
                      if (context.mounted) {
                        Navigator.pop(context);
                        showMessage(context, context.loc.importedSubject);
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                    label: Text(context.loc.add),
                  ),
                ],
              ),
            ),
          if (lesson.change != null)
            Text('${context.loc.change}: ${lesson.change?.description}'),
          if (lesson.teacher != null)
            Text('${context.loc.teacher}: ${lesson.teacher?.name}'),
          if (lesson.room != null) Text('${context.loc.room}: ${lesson.room}'),
        ],
      ),
      actions: [
        DialogActionButton(
          text: context.loc.close,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}
