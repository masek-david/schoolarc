import 'package:flutter/material.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';
import 'package:school_manager/screens/exams/widgets/exam_tile.dart';
import 'package:school_manager/data/priority_model.dart';

class ExamList extends StatelessWidget {
  const ExamList({
    super.key,
    required this.examList,
    required this.deleteExam,
    required this.editExam,
    this.showText = false,
    this.showDates = true,
    this.textFull = 'Exams',
    this.textEmpty,
  });

  final List<ExamDTO> examList;
  final Function(int dbIndex) deleteExam;
  final Function(int dbIndex) editExam;
  final bool showText;
  final bool showDates;
  final String textFull;
  final String? textEmpty;

  @override
  Widget build(BuildContext context) {
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
          child: ExamTile(
            exam: exam,
            showDeadline: false,
            priority: Priority(exam.priority, context),
            onDelete: (context) => deleteExam(exam.dbIndex),
            onEdit: () => editExam(exam.dbIndex),
          ),
        );
      }),
    ]);
  }
}
