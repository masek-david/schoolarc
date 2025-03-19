import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/screens/exams/exam_tile.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';

class MySearchBar extends ConsumerWidget {
  const MySearchBar({super.key});

  static const itemPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 4);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hw = <HomeworkDTO>[];
    ref.watch(hwSortedProvider).values.forEach(
      (element) {
        hw.insertAll(0, element);
      },
    );
    final exams = <ExamDTO>[];
    ref.watch(examSortedProvider).values.forEach(
      (element) {
        exams.insertAll(0, element);
      },
    );
    final subjects = ref.watch(subjectsSortedProvider);

    return SearchAnchor.bar(
      suggestionsBuilder: (context, controller) {
        final text = controller.value.text;
        if (text == '') return [];
        List<Widget> list = [];

        hw
            .where(
              (element) => element.containsText(text) && !element.isDeleted,
            )
            .forEach(
              (element) => list.add(Padding(
                padding: itemPadding,
                child: HomeworkTile(
                  hw: element,
                  onChangedCompletion: (p0) {},
                  onDelete: null,
                  onEdit: () {},
                  onConvert: null,
                  expUseHwOverlay: true,
                ),
              )),
            );
        exams
            .where(
              (element) => element.containsText(text) && !element.isDeleted,
            )
            .forEach(
              (element) => list.add(Padding(
                padding: itemPadding,
                child: ExamTile(
                  exam: element,
                  onDelete: null,
                  onEdit: () {},
                  onConvert: null,
                ),
              )),
            );
        subjects
            .where(
              (element) => element.containsText(text) && !element.isDeleted,
            )
            .forEach(
              (element) => list.add(Padding(
                padding: itemPadding,
                child: SubjectTile(
                  subject: element,
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
