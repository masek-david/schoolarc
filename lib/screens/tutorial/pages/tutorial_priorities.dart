import 'package:flutter/material.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/screens/exams/exam_tile.dart';
import 'package:school_manager/widgets/tile/hw_tile.dart';
import 'package:school_manager/screens/tutorial/animated_page.dart';
import 'package:school_manager/screens/tutorial/tutorial.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/widgets/priority_picker.dart';

class TutorialPriorities extends StatefulWidget {
  const TutorialPriorities({super.key});

  @override
  State<TutorialPriorities> createState() => _TutorialPrioritiesState();
}

class _TutorialPrioritiesState extends State<TutorialPriorities> {
  var priority = 0;

  late var hw = exampleHw(context.loc);
  late var exam = exampleExam(context.loc);

  @override
  Widget build(BuildContext context) {
    return AnimatedPage(
      padding: const EdgeInsetsGeometry.all(16),
      spacing: 16,
      children: [
        AnimatedItem(
          builder: (isShown) => HwTile(
            hw: hw.copyWith(priority: TaskPriority(priority)),
            onChangedCompletion: (p0) {},
            onDelete: () {
              showMessage(context, context.loc.tutorialHomeworkDelete);
            },
            onConvert: null,
            onEdit: () {},
          ),
        ),
        AnimatedItem(
          builder: (isShown) => ExamTile(
            exam: exam.copyWith(priority: TaskPriority(priority)),
            onDelete: () {
              showMessage(context, context.loc.tutorialExamDelete);
            },
            onEdit: () {},
            onConvert: null,
          ),
        ),
        AnimatedItem.spacer(height: 32),
        AnimatedItem(
          builder: (isShown) => Text(context.loc.tutorialPriorities),
        ),
        AnimatedItem.spacer(height: 16),
        AnimatedItem(
          builder: (isShown) => PriorityPicker(
            selectedPriority: priority,
            onSelected: (value) => setState(() {
              priority = value;
            }),
          ),
        ),
      ],
    );
  }
}
