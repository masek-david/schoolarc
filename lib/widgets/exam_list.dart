import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/screens/exams/exam_tile.dart';

class ExamList extends ConsumerWidget {
  const ExamList({
    super.key,
    required this.onDelete,
    required this.onEdit,
    required this.examList,
    required this.onConvert,
    this.draggable = false,
    this.showText = false,
    this.showDates = true,
    this.textFull = 'Exams',
    this.textEmpty,
  });

  final List<ExamDTO> examList;
  final void Function(ExamDTO exam) onDelete;
  final void Function(ExamDTO exam) onEdit;
  final void Function(ExamDTO exam) onConvert;
  final bool draggable;
  final bool showText;
  final bool showDates;
  final String textFull;
  final String? textEmpty;

  Widget buildTile(BuildContext context, WidgetRef ref, ExamDTO exam) {
    return ExamTile(
      exam: exam,
      showDeadline: false,
      onDelete: () => onDelete(exam),
      onEdit: () => onEdit(exam),
      onConvert: () => onConvert(exam),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (examList.isEmpty && showText)
        TextSeparator(
          text: textEmpty ?? 'No $textFull',
          greydOut: true,
        )
      else if (showText)
        TextSeparator(text: textFull),
      ...List.generate(examList.length, (index) {
        ExamDTO exam = examList[index];
        return Padding(
          padding: const EdgeInsets.all(5),
          child: draggable
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return LongPressDraggable(
                      data: exam,
                      onDragStarted: () => HapticFeedback.mediumImpact(),
                      feedback: SizedBox(
                        width: constraints.maxWidth,
                        child: Opacity(
                          opacity: 0.6,
                          child: buildTile(context, ref, exam),
                        ),
                      ),
                      child: buildTile(context, ref, exam),
                    );
                  },
                )
              : buildTile(context, ref, exam),
        );
      }),
    ]);
  }
}
