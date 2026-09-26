import 'package:flutter/material.dart';
import 'package:schoolarc/features/subjects/presentation/subject_picker.dart';
import 'package:schoolarc/features/timetable/domain/lesson_model.dart';
import 'package:schoolarc/features/timetable/domain/teacher_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';

class EditLessonDialog extends StatefulWidget {
  const EditLessonDialog({
    super.key,
    required this.lesson,
    required this.onSave,
    required this.subjects,
  });

  final Lesson lesson;
  final List<Subject> subjects;
  final void Function(Lesson lesson) onSave;

  @override
  State<EditLessonDialog> createState() => _EditLessonDialogState();
}

class _EditLessonDialogState extends State<EditLessonDialog> {
  late var subject = widget.lesson.subject;
  late var roomController = TextEditingController(text: widget.lesson.room);
  late var teacherController = TextEditingController(
    text: widget.lesson.teacher?.name,
  );
  late var teacherShortController = TextEditingController(
    text: widget.lesson.teacher?.shortcut,
  );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const .all(12),
      title: Text(
        subject?.name ?? context.loc.selectSubject,
        style: context.txt.headlineSmall,
      ),
      content: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        spacing: 8,
        children: [
          SubjectPicker(
            subjects: widget.subjects,
            pickedSubjectId: subject?.id,
            onSelected: (subject) => setState(() {
              this.subject = subject;
            }),
          ),
          TextField(
            controller: roomController,
            maxLength: 5,
            decoration: InputDecoration(
              hintText: context.loc.room,
              counterText: '',
            ),
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: TextField(
                  controller: teacherController,
                  decoration: InputDecoration(hintText: context.loc.teacher),
                ),
              ),
              SizedBox(
                width: 80,
                child: TextField(
                  maxLength: 5,
                  controller: teacherShortController,
                  decoration: const InputDecoration(
                    counterText: '',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        DialogActionButton(
          text: context.loc.cancel,
          onPressed: () => Navigator.pop(context),
        ),
        DialogActionButton(
          isDestructiveAction: true,
          text: context.loc.delete,
          onPressed: () {
            vibrate.medium();
            Navigator.pop(context);
            widget.onSave(const Lesson.empty());
          },
        ),
        DialogActionButton(
          isDefaultAction: true,
          text: context.loc.save,
          onPressed: () {
            vibrate.medium();
            Navigator.pop(context);
            widget.onSave(
              Lesson(
                subject: subject,
                room: roomController.text,
                teacher: Teacher(
                  name: teacherController.text,
                  shortcut: teacherShortController.text,
                ),
                change: widget.lesson.change,
              ),
            );
          },
        ),
      ],
    );
  }
}
