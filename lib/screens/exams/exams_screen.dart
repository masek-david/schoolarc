import 'package:flutter/material.dart';
import 'package:school_manager/data/exams_data/exam_service.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';
import 'package:school_manager/data/priority_model.dart';
import 'package:school_manager/screens/exams/widgets/priority_view.dart';
import 'package:school_manager/widgets/add_bottom_sheet/add_bottom_sheet.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  ExamService service = ExamService();
  late Map<int, List<ExamDTO>> examsByPriority = service.sortByPriority();
  late List<ExamDTO> completedExams = service.getCompletedExams();
  late List<Priority> priorities = List.generate(
    4,
    (index) => Priority(index, context),
  );

  // deletes exam and shows snackbar to undo it
  void deleteExam(int dbIndex) {
    service.deleteExam(dbIndex);
    updateListView();

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Exam deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            service.revertLastlyDeletedExam();
            updateListView();
          },
        ),
      ),
    );
  }

  void createNewExam() async {
    showAddBottomSheet(
      context,
      onSave: ({
        required date,
        required priority,
        subject,
        required text,
      }) async {
        await service.saveNewExam(
          date: date,
          priority: priority,
          subject: subject,
          text: text,
        );
        updateListView();
      },
    );
  }

  void editExam(int dbIndex) {
    ExamDTO currentlyEditedTask = service.getExam(dbIndex);

    showAddBottomSheet(
      context,
      initialName: currentlyEditedTask.text,
      initialSubject: currentlyEditedTask.subject,
      initialDate: currentlyEditedTask.deadline,
      initialPriority: currentlyEditedTask.priority,
      onSave: ({required date, required priority, subject, required text}) {
        service.saveEditedExam(
          date: date,
          priority: priority,
          subject: subject,
          text: text,
          dbIndex: dbIndex,
        );
        updateListView();
      },
    );
  }

  void reorderExam(
      int oldItemIndex, int oldPriority, int newItemIndex, int newPriority) {
    service.changeSequence(
        oldItemIndex, oldPriority, newItemIndex, newPriority);
    updateListView();
  }

  void updateListView() {
    if (mounted) {
      setState(() {
        examsByPriority = service.sortByPriority();
        completedExams = service.getCompletedExams();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PriorityView(
        examsByPriority: examsByPriority,
        completedExams: completedExams,
        priorities: priorities,
        createNewExam: createNewExam,
        deleteExam: deleteExam,
        editExam: editExam,
        reorderExam: reorderExam,
      ),
    );
  }
}
