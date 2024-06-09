import 'package:flutter/material.dart';
import 'package:school_manager/exams/data/exam_dto_model.dart';
import 'package:school_manager/exams/util/exam_tile.dart';
import 'package:school_manager/util/priority_model.dart';

class ListOfExams extends StatefulWidget {
  const ListOfExams({
    super.key,
    required this.context,
    required this.examList,
    this.priorityOfList,
    required this.deleteExam,
    required this.editExam,
  });

  final Function deleteExam;
  final Function editExam;

  final BuildContext context;
  final List<ExamDTO>? examList;
  final Priority? priorityOfList;

  @override
  State<ListOfExams> createState() => _ListOfExamsState();
}

class _ListOfExamsState extends State<ListOfExams> {
  @override
  Widget build(BuildContext context) {
    String titleText = 'Completed';
    Color titleTextColor = Colors.white;
    Color? tileBkgColor;
    bool initiallyExpanded = false;

    titleTextColor = Theme.of(widget.context).colorScheme.inverseSurface;

    if (widget.priorityOfList != null) {
      titleText = widget.priorityOfList!.name;
      titleTextColor = widget.priorityOfList!.color;
      initiallyExpanded = true;
      tileBkgColor = Theme.of(context).colorScheme.primary.withOpacity(0.1);
    }

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
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    titleText,
                    style: TextStyle(
                      color: titleTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    height: 25,
                    width: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSecondary,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      widget.examList!.length.toString(),
                    ),
                  ),
                ],
              ),
              initiallyExpanded: initiallyExpanded,
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
                      priority: Priority(exam.priority, context),
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
