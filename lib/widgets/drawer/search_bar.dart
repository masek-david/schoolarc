import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/screens/exams/exam_tile.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';
import 'package:school_manager/utils/task_functions.dart';

class MySearchBar extends ConsumerWidget {
  const MySearchBar({super.key});

  static const itemPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hws = ref
        .watch(hwProvider)
        .values
        .where((element) => !element.isDeleted)
        .toList();
    final exams = ref
        .watch(examProvider)
        .values
        .where((element) => !element.isDeleted)
        .toList();

    final tasks = [...hws, ...exams];

    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return (a.isCompleted ? 1 : 0).compareTo((b.isCompleted ? 1 : 0));
      }
      if (a.priority.index != b.priority.index) {
        return b.priority.index.compareTo(a.priority.index);
      }
      if (a.order != b.order) {
        return a.order.compareTo(b.order);
      }
      return 0;
    });
    final subjects = ref.watch(subjectsSortedProvider);

    return SearchAnchor.bar(
      suggestionsBuilder: (context, controller) {
        final text = controller.value.text;
        if (text == '') return [];
        List<Widget> list = [];

        tasks
            .where(
          (task) => task.containsText(text) && !task.isDeleted,
        )
            .forEach(
          (task) {
            late Widget item;
            if (task.runtimeType == Homework) {
              item = HomeworkTile(
                hw: task as Homework,
                onChangedCompletion: (p0) {},
                onDelete: null,
                onEdit: () {
                  editHw(context, ref, task);
                },
                onConvert: null,
                expUseHwOverlay: true,
              );
            } else {
              item = ExamTile(
                exam: task as Exam,
                onDelete: null,
                onEdit: () {
                  editExam(context, ref, task);
                },
                onConvert: null,
              );
            }

            list.add(
              Padding(
                padding: itemPadding,
                child: item,
              ),
            );
          },
        );
        subjects
            .where(
              (subject) => subject.containsText(text) && !subject.isDeleted,
            )
            .forEach(
              (subject) => list.add(Padding(
                padding: itemPadding,
                child: SubjectTile(
                  subject: subject,
                  onTap: () {},
                  onDelete: null,
                ),
              )),
            );

        return list;
      },
    );
  }
}
