import 'package:flutter/material.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/screens/tutorial/tutorial.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/priority_picker.dart';
import 'package:schoolarc/widgets/tiles/exam_tile.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';

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
        AnimatedItem(
          builder: (isShown) => Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Text(context.loc.tutorialPriorities),
          ),
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
