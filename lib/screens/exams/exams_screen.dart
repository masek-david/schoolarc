import 'package:flutter/material.dart';
import 'package:school_manager/screens/exams/widgets/priority_view.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/screen_size.dart';
import 'package:school_manager/widgets/wide_screen_app_bar.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  late var examsByPriority = examService.sortByPriority();
  late var completedExams = examService.getCompletedExams();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    updateView();
  }

  void updateView() {
    if (mounted) {
      setState(() {
        examsByPriority = examService.sortByPriority();
        completedExams = examService.getCompletedExams();
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
    return ValueListenableBuilder(
      valueListenable: ScreenSize.isWideScreen,
      builder: (context, isWide, child) {
        return Scaffold(
          appBar: WideScreenAppBar(
            isWideScreen: isWide,
            title: const Text('Exams'),
          ),
          body: PriorityView(
            examsByPriority: examsByPriority,
            completedExams: completedExams,
            updateView: updateView,
            reorderExam: reorderExam,
          ),
        );
      },
    );
  }
}
