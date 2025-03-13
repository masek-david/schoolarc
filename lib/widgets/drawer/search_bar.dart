import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/screens/exams/widgets/exam_tile.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';

class MySearchBar extends ConsumerWidget {
  const MySearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hw = ref.watch(hwProvider);
    final exams = ref.watch(examProvider);
    final subjects = ref.watch(subjectsProvider);

    return SearchAnchor.bar(
      suggestionsBuilder: (context, controller) {
        final text = controller.value.text;
        if (text == '') return [];
        List<Widget> list = [];

        hw.values
            .where(
              (element) => element.containsText(text),
            )
            .forEach(
              (element) => list.add(Padding(
                padding: const EdgeInsets.all(8.0),
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
        exams.values
            .where(
              (element) => element.containsText(text),
            )
            .forEach(
              (element) => list.add(Padding(
                padding: const EdgeInsets.all(8.0),
                child: ExamTile(
                  exam: element,
                  onDelete: null,
                  onEdit: () {},
                  onConvert: null,
                ),
              )),
            );
        subjects.values
            .where(
              (element) => element.containsText(text),
            )
            .forEach(
              (element) => list.add(Padding(
                padding: const EdgeInsets.all(8.0),
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
