import 'package:flutter/material.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/screens/tutorial/tutorial.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/tiles/exam_tile.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';

class TutorialSubjects extends StatefulWidget {
  const TutorialSubjects({super.key});

  @override
  State<TutorialSubjects> createState() => _TutorialSubjectsState();
}

class _TutorialSubjectsState extends State<TutorialSubjects> {
  late final subjects = [
    sub,
    Subject(
      name: context.loc.exampleSubjectName2,
      shortcut: context.loc.exampleSubjectShort2,
      id: '',
      bakaId: '',
      timestamp: DateTime.now(),
      isDeleted: false,
      order: 0,
      isShared: false,
    ),
    Subject(
      name: context.loc.exampleSubjectName3,
      shortcut: context.loc.exampleSubjectShort3,
      id: '',
      bakaId: '',
      timestamp: DateTime.now(),
      isDeleted: false,
      order: 0,
      isShared: false,
    ),
  ];
  late var sub = exampleSubject(context.loc);
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
            hw: hw.copyWith(subject: sub),
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
            exam: exam.copyWith(subject: sub),
            onDelete: () {
              showMessage(context, context.loc.tutorialExamDelete);
            },
            onEdit: () {},
            onConvert: null,
          ),
        ),
        AnimatedItem.spacer(height: 32),
        AnimatedItem(
          builder: (isShown) => Text(context.loc.tutorialTryAssigningSubject),
        ),
        AnimatedItem(
          builder: (isShown) => SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                var current = subjects[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(current.name),
                    selected: current.name == sub.name,
                    onSelected: (value) {
                      setState(() {
                        sub = current;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ),
        AnimatedItem(
          builder: (isShown) => Text(context.loc.tutorialCreateSubjectsLater),
        ),
      ],
    );
  }
}
