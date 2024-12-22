import 'package:flutter/material.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';

class RescheduleDragTarget extends StatelessWidget {
  const RescheduleDragTarget({
    super.key,
    required this.builder,
    required this.updateView,
    required this.currentDate,
    this.onMove,
  });

  final Widget Function(BuildContext context, List<Object?> candidateData,
      List<dynamic> rejectedData) builder;
  final void Function(DragTargetDetails<Object>)? onMove;

  final void Function() updateView;
  final DateTime currentDate;

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      onMove: onMove,
      onAcceptWithDetails: (details) async {
        if (details.data.runtimeType == HomeworkDTO) {
          final hw = details.data as HomeworkDTO;
          if (!hw.deadline.isSameDay(currentDate)) {
            await homeworkService.saveEditedHW(
              date: currentDate.toLocal(),
              priority: hw.priority.index,
              subject: hw.subject,
              text: hw.text,
              description: hw.description,
              dbIndex: hw.dbIndex,
            );
            updateView();
          }
        }
        if (details.data.runtimeType == ExamDTO) {
          final exam = details.data as ExamDTO;
          if (!exam.deadline.isSameDay(currentDate)) {
            await examService.saveEditedExam(
              date: currentDate.toLocal(),
              priority: exam.priority.index,
              subject: exam.subject,
              text: exam.text,
              description: exam.description,
              dbIndex: exam.dbIndex,
            );
            updateView();
          }
        }
      },
      builder: builder,
    );
  }
}
