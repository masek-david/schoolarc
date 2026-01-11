import 'package:flutter/material.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/screens/tutorial/tutorial.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/tiles/exam_tile.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';

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
            style: context.txt.titleMedium,
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
            style: context.txt.titleMedium,
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
