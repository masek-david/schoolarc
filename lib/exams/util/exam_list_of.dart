import 'package:flutter/material.dart';
import 'package:school_manager/exams/data/exam_dto_model.dart';
import 'package:school_manager/exams/util/exam_tile.dart';
import 'package:school_manager/util/priority_model.dart';

class ListOfExams extends StatefulWidget {
  const ListOfExams({
    super.key,
    required this.examList,
    required this.priority,
    required this.deleteExam,
    required this.editExam,
  });

  final Function deleteExam;
  final Function editExam;

  final List<ExamDTO>? examList;
  final Priority priority;

  @override
  State<ListOfExams> createState() => _ListOfExamsState();
}

class _ListOfExamsState extends State<ListOfExams> {
  @override
  Widget build(BuildContext context) {
    String titleText = widget.priority.name;
    Color titleTextColor = widget.priority.color;

    Color tileBkgColor = ElevationOverlay.applySurfaceTint(
        Theme.of(context).colorScheme.surface,
        Theme.of(context).colorScheme.primary,
        0.8);

    if (widget.examList!.isEmpty) {
      return const SizedBox();
    }
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: tileBkgColor,
      ),
      child: Column(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              listTileTheme: ListTileTheme.of(context).copyWith(
                dense: true,
                visualDensity: VisualDensity.compact,
              ),
            ),
            child: ExpansionTile(
              title: Text(
                titleText,
                style: TextStyle(
                  color: titleTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              initiallyExpanded: true,
              shape: const Border(),
              children: [
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.examList!.length,
                  itemBuilder: (context, indexInSortedList) {
                    if (widget.examList == null && widget.examList!.isEmpty) {
                      return null;
                    }
                    ExamDTO exam = widget.examList![indexInSortedList];
                    return ExamTile(
                      text: exam.text,
                      deadline: exam.date,
                      subject: exam.subject,
                      priority: widget.priority,
                      onDelete: (context) => widget.deleteExam(exam.index),
                      onEdit: () => widget.editExam(exam.index),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
