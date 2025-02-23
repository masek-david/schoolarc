import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/task_model.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/add_bottom_sheet/add_bottom_sheet.dart';

Future<void> addNewHw(
  BuildContext context,
  WidgetRef ref, {
  DateTime? initialDate,
}) async {
  final newHw = await showModalBottomSheet<Task?>(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddTaskBottomSheet(
      initialTask: Task.empty().copyWith(deadline: initialDate),
      autoSetDate: true,
    ),
  );

  if (newHw != null) {
    ref.read(hwProvider.notifier).saveNew(newHw.toHw());
  }
  return;
}

void editHw(BuildContext context, WidgetRef ref, HomeworkDTO hw) async {
  HomeworkDTO? edited = await showModalBottomSheet<HomeworkDTO>(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddTaskBottomSheet(
      initialTask: hw,
      autoSetDate: false,
    ),
  );

  if (edited != null) {
    ref.read(hwProvider.notifier).edit(edited);
  }
}

void completeHw(
    BuildContext context, WidgetRef ref, HomeworkDTO hw, bool value) {
  ref.read(hwProvider.notifier).complete(hw, value);
}

void deleteHw(BuildContext context, WidgetRef ref, HomeworkDTO hw) {
  ref.read(hwProvider.notifier).delete(hw);

  showMessage(context, 'Deleted homework ${hw.text}', actions: [
    SnackBarAction(
      label: 'Undo',
      onPressed: () {
        ref.read(hwProvider.notifier).revertDelete(hw);
      },
    ),
  ]);
}

Future<void> addNewExam(
  BuildContext context,
  WidgetRef ref, {
  DateTime? initialDate,
}) async {
  final newExam = await showModalBottomSheet<Task?>(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddTaskBottomSheet(
      initialTask: Task.empty().copyWith(deadline: initialDate),
      autoSetDate: true,
    ),
  );

  if (newExam != null) {
    ref.read(examProvider.notifier).saveNew(newExam.toExam());
  }
}

void editExam(BuildContext context, WidgetRef ref, ExamDTO exam) async {
  ExamDTO? edited = await showModalBottomSheet<ExamDTO>(
    context: context,
    isScrollControlled: true,
    builder: (context) => AddTaskBottomSheet(
      initialTask: exam,
      autoSetDate: false,
    ),
  );

  if (edited != null) {
    ref.read(examProvider.notifier).edit(edited);
  }
}

void deleteExam(BuildContext context, WidgetRef ref, ExamDTO exam) {
  ref.read(examProvider.notifier).delete(exam);

  showMessage(context, 'Deleted exan ${exam.text}', actions: [
    SnackBarAction(
      label: 'Undo',
      onPressed: () {
        ref.read(examProvider.notifier).revertDelete(exam);
      },
    ),
  ]);
}
