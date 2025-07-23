import 'package:flutter/material.dart';
import 'package:school_manager/screens/main_screens/exams/exam_tile.dart';
import 'package:school_manager/screens/tutorial/animated_page.dart';
import 'package:school_manager/screens/tutorial/tutorial.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/globals.dart';
import 'package:school_manager/widgets/tile/hw_tile.dart';

class TutorialBasics extends StatelessWidget {
  const TutorialBasics({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = context.loc;
    
    return AnimatedPage(
      padding: const EdgeInsetsGeometry.all(16),
      spacing: 16,
      children: [
        AnimatedItem(
          builder: (isShown) => Text(
            loc.tutorialHomeworkTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        AnimatedItem(
          builder: (isShown) => HwTile(
            hw: exampleHw(loc),
            onChangedCompletion: (p0) {},
            onDelete: () {
              showMessage(context, loc.tutorialHomeworkDelete);
            },
            onConvert: null,
            onEdit: () {},
          ),
        ),
        AnimatedItem(
          builder: (isShown) => Text(
            loc.tutorialExamTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        AnimatedItem(
          builder: (isShown) => ExamTile(
            exam: exampleExam(loc),
            onDelete: () {
              showMessage(context, loc.tutorialExamDelete);
            },
            onEdit: () {},
            onConvert: null,
          ),
        ),
      ],
    );
  }
}
