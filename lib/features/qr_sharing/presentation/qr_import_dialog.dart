import 'package:flutter/material.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart' show Homework;
import 'package:schoolarc/models/task_model.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';
import 'package:schoolarc/widgets/tiles/exam_tile.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';

Future<void> showQrImportDialog(
  BuildContext context,
  Task task,
  void Function(bool isHomework) onImport,
) {
  return showDialog(
    context: context,
    builder: (context) => QrImportDialog(
      task: task,
      onImport: onImport,
    ),
  );
}

class QrImportDialog extends StatelessWidget {
  const QrImportDialog({
    super.key,
    required this.task,
    required this.onImport,
  });

  final Task task;
  final void Function(bool isHomework) onImport;

  @override
  Widget build(BuildContext context) {
    final isHomework = task is Homework;

    return AlertDialog(
      title: Text(context.loc.import),
      actions: [
        DialogActionButton(
          text: context.loc.close,
          onPressed: () => Navigator.pop(context),
        ),
        DialogActionButton(
          isDefaultAction: true,
          text: context.loc.import,
          onPressed: () {
            Navigator.pop(context);
            onImport(isHomework);
          },
        ),
      ],
      content: SizedBox(
        height: 60,
        width: 280,
        child: task is Homework
            ? HwTile(
                hw: task as Homework,
                onChangedCompletion: null,
                onDelete: null,
                onEdit: () {},
                onConvert: null,
              )
            : ExamTile(
                exam: task as Exam,
                onDelete: null,
                onEdit: () {},
                onConvert: null,
              ),
      ),
    );
  }
}
