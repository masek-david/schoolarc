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
    String titleText = 'Past';
    Color titleTextColor = Theme.of(widget.context).colorScheme.inverseSurface;
    Color? tileBkgColor;
    bool initiallyExpanded = false;

    if (widget.priorityOfList != null) {
      titleText = widget.priorityOfList!.name;
      titleTextColor = widget.priorityOfList!.color;
      initiallyExpanded = true;
      tileBkgColor = Theme.of(context).colorScheme.primary.withAlpha(20);
    }

    if (widget.examList!.isEmpty) {
      return const SizedBox();
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          listTileTheme: ListTileTheme.of(context).copyWith(
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        ),
        child: ExpansionTile(
          collapsedBackgroundColor: tileBkgColor,
          initiallyExpanded: initiallyExpanded,
          shape: const Border(),
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
                height: 22,
                width: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(10),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  widget.examList!.length.toString(),
                ),
              ),
            ],
          ),
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: widget.examList!.length,
              itemBuilder: (context, indexInSortedList) {
                if (widget.examList == null && widget.examList!.isEmpty) {
                  return null;
                }
                
                // sets padding only between the tiles, not top or bottom
                EdgeInsetsGeometry padding = const EdgeInsets.only(top: 10);
                if (indexInSortedList == 0){
                  padding = EdgeInsets.zero;
                }
                
                ExamDTO exam = widget.examList![indexInSortedList];
                return Padding(
                  padding: padding,
                  child: ExamTile(
                    text: exam.text,
                    deadline: exam.date,
                    subject: exam.subject,
                    priority: Priority(exam.priority, context),
                    completion: exam.isCompleted,
                    onDelete: (context) => widget.deleteExam(exam.index),
                    onEdit: () => widget.editExam(exam.index),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
