import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';

class RescheduleDragTarget extends ConsumerWidget {
  const RescheduleDragTarget({
    super.key,
    required this.builder,
    required this.currentDate,
    this.onMove,
  });

  final Widget Function(BuildContext context, List<Object?> candidateData,
      List<dynamic> rejectedData) builder;
  final void Function(DragTargetDetails<Object>)? onMove;

  final DateTime currentDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DragTarget(
      onMove: onMove,
      onAcceptWithDetails: (details) async {
        if (details.data.runtimeType == Homework) {
          final hw = details.data as Homework;
          if (!hw.deadline.isSameDay(currentDate)) {
            ref.read(hwProvider.notifier).edit(
                  hw.copyWith(
                    deadline: currentDate.toLocal(),
                    timestamp: DateTime.now().toUtc(),
                  ),
                );
          }
        }
        if (details.data.runtimeType == Exam) {
          final exam = details.data as Exam;
          if (!exam.deadline.isSameDay(currentDate)) {
            ref.read(examProvider.notifier).edit(
                  exam.copyWith(
                    deadline: currentDate.toLocal(),
                    timestamp: DateTime.now().toUtc(),
                  ),
                );
          }
        }
      },
      builder: builder,
    );
  }
}
