import 'package:flutter/material.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/screens/main_screens/exams/exam_tile.dart';
import 'package:school_manager/screens/tutorial/animated_page.dart';
import 'package:school_manager/screens/tutorial/tutorial.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/globals.dart';
import 'package:school_manager/widgets/tile/hw_tile.dart';

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
    ),
    Subject(
      name: context.loc.exampleSubjectName3,
      shortcut: context.loc.exampleSubjectShort3,
      id: '',
      bakaId: '',
      timestamp: DateTime.now(),
      isDeleted: false,
      order: 0,
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
