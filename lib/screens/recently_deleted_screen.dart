import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/screens/exams/exam_tile.dart';
import 'package:school_manager/widgets/tile/hw_tile.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';

class RecentlyDeletedScreen extends ConsumerWidget {
  const RecentlyDeletedScreen({super.key});

  void recover({
    required BuildContext context,
    required WidgetRef ref,
    required item,
  }) {
    String itemName = '';
    Function onRevert = () => throw 'No valid item';

    switch (item.runtimeType) {
      case const (Homework):
        {
          final hw = item as Homework;
          itemName = hw.text;
          onRevert = () => ref.read(hwProvider.notifier).revertDelete(hw);
        }
      case const (Exam):
        {
          final exam = item as Exam;
          itemName = exam.text;
          onRevert = () => ref.read(examProvider.notifier).revertDelete(exam);
        }
      case const (Subject):
        {
          final subject = item as Subject;
          itemName = subject.name;
          onRevert =
              () => ref.read(subjectsProvider.notifier).revertDelete(subject);
        }
    }

    showDialogAdaptive(
        context: context,
        title: Text('${context.loc.recover}?'),
        content: Text('${context.loc.recover} \'$itemName\'?'),
        actions: [
          adaptiveDialogButton(
            context: context,
            child: Text(context.loc.cancel),
            onPressed: () => Navigator.pop(context),
          ),
          adaptiveDialogButton(
              context: context,
              isDefaultAction: true,
              child: Text(context.loc.recover),
              onPressed: () {
                onRevert();
                Navigator.pop(context);
              }),
        ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hws = ref.watch(hwDeletedProvider);
    final exams = ref.watch(examDeletedProvider);
    final subjects = ref.watch(subjectsDeletedProvider);
    final textColor = Theme.of(context).colorScheme.error;

    final List<dynamic> items = [...hws, ...exams, ...subjects];

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.recentlyDeleted),
        actions: [
          IconButton(
            onPressed: () => showDialogAdaptive(
              context: context,
              title: Text(context.loc.recover),
              content: Text(context.loc.recoverInfoContent),
              actions: [
                adaptiveDialogButton(
                  context: context,
                  child: Text(context.loc.close),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final now = DateTime.now();
          int daysLeft = 7;

          Widget? tile;
          switch (item.runtimeType) {
            case const (Homework):
              {
                daysLeft =
                    7 + (item as Homework).timestamp.difference(now).inDays;
                tile = HwTile(
                  hw: item,
                  showBorderIfMissed: false,
                  onChangedCompletion: null,
                  onDelete: null,
                  onEdit: () => recover(context: context, ref: ref, item: item),
                  onConvert: null,
                );
              }
            case const (Exam):
              {
                daysLeft = 7 + (item as Exam).timestamp.difference(now).inDays;
                tile = ExamTile(
                  exam: item,
                  onDelete: null,
                  onEdit: () => recover(context: context, ref: ref, item: item),
                  onConvert: null,
                );
              }
            case const (Subject):
              {
                daysLeft =
                    7 + (item as Subject).timestamp.difference(now).inDays;
                tile = SubjectTile(
                  subject: item,
                  onDelete: kDebugMode
                      ? () {
                          subjectsDb.delete(item.id);
                          firebaseService.deleteSubjects([item]);
                        }
                      : null,
                  onTap: () => recover(context: context, ref: ref, item: item),
                );
              }
          }

          assert(tile != null);

          return Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                tile!,
                Text(
                  context.loc.daysLeft(daysLeft),
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
