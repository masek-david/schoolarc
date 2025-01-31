import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';

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
        if (details.data.runtimeType == HomeworkDTO) {
          final hw = details.data as HomeworkDTO;
          if (!hw.deadline.isSameDay(currentDate)) {
            ref.read(hwProvider.notifier).edit(
                  hw.copyWith(
                    deadline: currentDate.toLocal(),
                    timestamp: Timestamp.now(),
                  ),
                );
          }
        }
        if (details.data.runtimeType == ExamDTO) {
          final exam = details.data as ExamDTO;
          if (!exam.deadline.isSameDay(currentDate)) {
            ref.read(examProvider.notifier).edit(
                  exam.copyWith(
                    deadline: currentDate.toLocal(),
                    timestamp: Timestamp.now(),
                  ),
                );
          }
        }
      },
      builder: builder,
    );
  }
}
