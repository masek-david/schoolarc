import 'package:flutter/material.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';
import 'package:school_manager/screens/exams/widgets/exam_tile.dart';
import 'package:school_manager/data/priority_model.dart';

class CalendarListExam extends StatelessWidget {
  const CalendarListExam(
      {super.key,
      required this.examList,
      required this.deleteExam,
      required this.editExam});

  final List<ExamDTO> examList;
  final Function(int dbIndex) deleteExam;
  final Function(int dbIndex) editExam;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(examList.length + 1, (index) {
        if (examList.isEmpty) {
          return const TextSeparator(
            text: 'No Exams',
            greydOut: true,
          );
        }

        if (index == 0) {
          return const TextSeparator(text: 'Exams');
        }

        ExamDTO exam = examList[index - 1];
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
    );
  }
}
