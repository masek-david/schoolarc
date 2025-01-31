import 'package:flutter/material.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/screens/exams/widgets/exam_tile.dart';
import 'package:school_manager/tasks_app.dart';

class ExamList extends StatelessWidget {
  const ExamList({
    super.key,
    required this.examList,
    required this.updateView,
    this.draggable = false,
    this.showText = false,
    this.showDates = true,
    this.textFull = 'Exams',
    this.textEmpty,
  });

  final List<ExamDTO> examList;
  final void Function() updateView;
  final bool draggable;
  final bool showText;
  final bool showDates;
  final String textFull;
  final String? textEmpty;

  Widget buildTile(BuildContext context, ExamDTO exam) {
    return ExamTile(
      exam: exam,
      showDeadline: false,
      onDelete: () =>
          deleteExam(context, exam, () => updateView()).then(
        (value) => updateView(),
      ),
      onEdit: () => editExam(context, exam.dbIndex).then(
        (value) => updateView(),
      ),
    );
  }

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
          child: draggable
              ? LayoutBuilder(
                  builder: (context, constraints) {
                    return LongPressDraggable(
                      data: exam,
                      feedback: SizedBox(
                        width: constraints.maxWidth,
                        child: Opacity(
                          opacity: 0.6,
                          child: buildTile(context, exam),
                        ),
                      ),
                      child: buildTile(context, exam),
                    );
                  },
                )
              : buildTile(context, exam),
        );
      }),
    ]);
  }
}
