import 'package:flutter/material.dart';
import 'package:school_manager/screens/exams/widgets/priority_view.dart';
import 'package:school_manager/tasks_app.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  late var examsByPriority = examService.sortByPriority(null);
  late var completedExams = examService.getCompletedExams(null);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    updateView();
  }

  void updateView() {
    if (mounted) {
      setState(() {
        examsByPriority = examService.sortByPriority(context);
        completedExams = examService.getCompletedExams(context);
      });
    }
  }

  void reorderExam(
      int oldItemIndex, int oldPriority, int newItemIndex, int newPriority) {
    examService.changeSequence(
        oldItemIndex, oldPriority, newItemIndex, newPriority);
    updateView();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const DrawerButton(
          onPressed: switchDrawer,
        ),
        title: const Text('Exams'),
      ),
      body: PriorityView(
        examsByPriority: examsByPriority,
        completedExams: completedExams,
        updateView: updateView,
        reorderExam: reorderExam,
      ),
    );
  }
}
