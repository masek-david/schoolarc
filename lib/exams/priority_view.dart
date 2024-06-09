import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/exams/util/exam_list_of.dart';
import 'package:school_manager/util/priority_model.dart';
import 'package:school_manager/exams/data/exam_dto_model.dart';

class PriorityView extends StatefulWidget {
  const PriorityView({
    super.key,
    required this.examsByPriority,
    required this.completedExams,
    required this.createNewExam,
    required this.deleteExam,
    required this.editExam,
  });

  final Map<int, List<ExamDTO>> examsByPriority;
  final List<ExamDTO> completedExams;
  final Function createNewExam;
  final Function editExam;
  final Function deleteExam;

  @override
  State<PriorityView> createState() => _PriorityViewState();
}

class _PriorityViewState extends State<PriorityView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.createNewExam();
          HapticFeedback.lightImpact();
        },
        enableFeedback: true,
        child: const Icon(Icons.add),
      ),
      body: SlidableAutoCloseBehavior(
        child: ListView.builder(
          itemCount: 6,
          itemBuilder: (context, index) {
            final priorityIndex = 4 - 1 - index; // obrati index
            if (index == 4) {
              return ListOfExams(
                context: context,
                examList: widget.completedExams,
                deleteExam: widget.deleteExam,
                editExam: widget.editExam,
              );
            }
            if (index == 5) {
              return const SizedBox(height: 70);
            }
            return ListOfExams(
              context: context,
              examList: widget.examsByPriority[priorityIndex],
              priorityOfList: Priority(priorityIndex, context),
              deleteExam: widget.deleteExam,
              editExam: widget.editExam,
            );
          },
        ),
      ),
    );
  }
}
