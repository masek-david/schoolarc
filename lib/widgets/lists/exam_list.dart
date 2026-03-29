import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/text_actions.dart';
import 'package:schoolarc/widgets/tiles/exam_tile.dart';

class ExamList extends ConsumerWidget {
  const ExamList({
    super.key,
    required this.examList,
    required this.onDelete,
    required this.onEdit,
    required this.onConvert,
    required this.text,
    this.draggable = false,
    this.showDates = true,
  });

  final List<Exam> examList;
  final void Function(Exam exam) onDelete;
  final void Function(Exam exam) onEdit;
  final void Function(Exam exam) onConvert;
  final bool draggable;
  final String text;
  final bool showDates;

  Widget buildTile(BuildContext context, WidgetRef ref, Exam exam) {
    return ExamTile(
      exam: exam,
      showDeadline: showDates,
      onDelete: () => onDelete(exam),
      onEdit: () => onEdit(exam),
      onConvert: () => onConvert(exam),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRect(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextActions(text: text, greydOut: examList.isEmpty),
          ...List.generate(
            examList.length,
            (index) {
              Exam exam = examList[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: draggable
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return LongPressDraggable(
                            data: exam,
                            onDragStarted: vibrate.medium,
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
            },
          ),
        ],
      ),
    );
  }
}
