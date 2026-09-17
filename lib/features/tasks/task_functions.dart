import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:schoolarc/features/tasks/presentation/edit_task_bottom_sheet.dart';
import 'package:schoolarc/features/tasks/presentation/edit_task_state.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/task_data_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';

// This file doesnt have tests

Future<void> _showEditTaskBottomSheet(
  BuildContext context,
  EditTaskState state,
) async {
  try {
    while (true) {
      if (!context.mounted) return;
      final result = await showModalBottomSheet<bool>(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (context) => EditTaskBottomSheet(state: state),
      );

      if (result == true || !state.hasUnsavedData() || !context.mounted) {
        return;
      }

      final shouldDiscard = await _showShouldDiscardDialog(context);

      if (shouldDiscard) {
        return;
      }
    }
  } finally {
    Future.delayed(const Duration(seconds: 1), () => state.dispose());
  }
}

Future<bool> _showShouldDiscardDialog(BuildContext context) {
  return showMyDialog(
    dismissible: false,
    context: context,
    title: 'Discard edit?',
    actions: [
      DialogActionButton(
        text: 'Cancel',
        onPressed: () => Navigator.pop(context, false),
      ),
      DialogActionButton(
        isDestructiveAction: true,
        text: 'Discard',
        onPressed: () => Navigator.pop(context, true),
      ),
    ],
  );
}

Future<void> addNewHw(BuildContext context, {Date? initialDate}) async {
  Posthog().capture(eventName: 'Creating Homework');

  final state = EditTaskState(
    isHomework: true,
    autoSetDateToNextSubjectDate: initialDate == null,
    initialTask: TaskData.empty().copyWith(date: initialDate),
  );

  _showEditTaskBottomSheet(context, state);
}

void editHw(BuildContext context, Homework hw) {
  Posthog().capture(eventName: 'Editing Homework');

  final state = EditTaskState(
    isHomework: true,
    autoSetDateToNextSubjectDate: false,
    initialTask: hw.toData(),
  );

  _showEditTaskBottomSheet(context, state);
}

void convertHw(BuildContext context, WidgetRef ref, Homework hw) {
  ref.read(hwDataProvider.notifier).convert(hw.toData());
}

void completeHw(BuildContext context, WidgetRef ref, Homework hw, bool value) {
  ref.read(hwDataProvider.notifier).complete(hw.toData(), value);
}

void deleteHw(BuildContext context, WidgetRef ref, Homework hw) {
  ref.read(hwDataProvider.notifier).delete(hw.toData());

  showMessage(
    context,
    '${context.loc.deletedHomework} \'${hw.text}\'',
    actions: [
      SnackBarAction(
        label: context.loc.undo,
        onPressed: () {
          ref.read(hwDataProvider.notifier).revertDelete(hw.toData());
        },
      ),
    ],
  );
}

void addNewExam(BuildContext context, {Date? initialDate}) {
  Posthog().capture(eventName: 'Creating Exam');

  final state = EditTaskState(
    isHomework: false,
    autoSetDateToNextSubjectDate: initialDate == null,
    initialTask: TaskData.empty().copyWith(date: initialDate),
  );

  _showEditTaskBottomSheet(context, state);
}

void editExam(BuildContext context, Exam exam) {
  Posthog().capture(eventName: 'Editing Exam');

  final state = EditTaskState(
    isHomework: false,
    autoSetDateToNextSubjectDate: false,
    initialTask: exam.toData(),
  );

  _showEditTaskBottomSheet(context, state);
}

void convertExam(BuildContext context, WidgetRef ref, Exam exam) {
  ref.read(examDataProvider.notifier).convert(exam.toData());
}

void deleteExam(BuildContext context, WidgetRef ref, Exam exam) {
  ref.read(examDataProvider.notifier).delete(exam.toData());

  showMessage(
    context,
    '${context.loc.deletedExam} \'${exam.text}\'',
    actions: [
      SnackBarAction(
        label: context.loc.undo,
        onPressed: () {
          ref.read(examDataProvider.notifier).revertDelete(exam.toData());
        },
      ),
    ],
  );
}
