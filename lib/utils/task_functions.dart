import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/add_bottom_sheet.dart';

@pragma('vm:entry-point')
Route<void> bottomSheetRoute(BuildContext context, Object? arguments) {
  assert(arguments is Map);
  arguments as Map;

  final initialDateInt = arguments['date'] as int?;
  final initialDate =
      initialDateInt != null ? Date.fromPrimitiveInt(initialDateInt) : null;

  return ModalBottomSheetRoute(
    builder: (context) => AddTaskBottomSheet(
      initialTaskId: arguments['id'],
      initialDate: initialDate,
      isHomework: arguments['isHomework'],
      autoSetDate: initialDate == null,
    ),
    isScrollControlled: true,
  );
}

// TODO it doesnt return future
Future<void> addNewHw(BuildContext context, {Date? initialDate}) async {
  Navigator.restorablePush(context, bottomSheetRoute, arguments: {
    'date': initialDate?.toPrimitiveInt(),
    'id': null,
    'isHomework': true,
  });
}

void editHw(BuildContext context, Homework hw) async {
  Navigator.restorablePush(context, bottomSheetRoute, arguments: {
    'date': hw.date.toPrimitiveInt(),
    'id': hw.id,
    'isHomework': true,
  });
}

void convertHw(BuildContext context, WidgetRef ref, Homework hw) {
  ref.read(hwProvider.notifier).convert(hw);
}

void completeHw(BuildContext context, WidgetRef ref, Homework hw, bool value) {
  ref.read(hwProvider.notifier).complete(hw, value);
}

void deleteHw(BuildContext context, WidgetRef ref, Homework hw) {
  ref.read(hwProvider.notifier).delete(hw);

  showMessage(
    context,
    '${context.loc.deletedHomework} \'${hw.text}\'',
    actions: [
      SnackBarAction(
        label: context.loc.undo,
        onPressed: () {
          ref.read(hwProvider.notifier).revertDelete(hw);
        },
      ),
    ],
  );
}

Future<void> addNewExam(BuildContext context, {Date? initialDate}) async {
  Navigator.restorablePush(context, bottomSheetRoute, arguments: {
    'date': initialDate?.toPrimitiveInt(),
    'id': null,
    'isHomework': false,
  });
}

void editExam(BuildContext context, Exam exam) async {
  Navigator.restorablePush(context, bottomSheetRoute, arguments: {
    'date': exam.date.toPrimitiveInt(),
    'id': exam.id,
    'isHomework': false,
  });
}

void convertExam(BuildContext context, WidgetRef ref, Exam exam) {
  ref.read(examProvider.notifier).convert(exam);
}

void deleteExam(BuildContext context, WidgetRef ref, Exam exam) {
  ref.read(examProvider.notifier).delete(exam);

  showMessage(context, '${context.loc.deletedExam} \'${exam.text}\'', actions: [
    SnackBarAction(
      label: context.loc.undo,
      onPressed: () {
        ref.read(examProvider.notifier).revertDelete(exam);
      },
    ),
  ]);
}
