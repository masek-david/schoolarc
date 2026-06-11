import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/screens/subjects/widgets/subject_tile.dart';
import 'package:schoolarc/utils/task_functions.dart';
import 'package:schoolarc/widgets/tiles/exam_tile.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';

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
      if (a.date != b.date) {
        return b.date.compareTo(a.date);
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
                  item = HwTile(
                    hw: task as Homework,
                    onChangedCompletion: (p0) {},
                    onDelete: null,
                    onEdit: () {
                      editHw(context, task);
                    },
                    onConvert: null,
                  );
                } else {
                  item = ExamTile(
                    exam: task as Exam,
                    onDelete: null,
                    onEdit: () {
                      editExam(context, task);
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
              (subject) => list.add(
                Padding(
                  padding: itemPadding,
                  child: SubjectTile(
                    subject: subject,
                    onTap: () {},
                    onDelete: null,
                  ),
                ),
              ),
            );

        return list;
      },
    );
  }
}
