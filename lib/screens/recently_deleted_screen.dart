import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/screens/exams/exam_tile.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';
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
      case const (HomeworkDTO):
        {
          final hw = item as HomeworkDTO;
          itemName = hw.text;
          onRevert = () => ref.read(hwProvider.notifier).revertDelete(hw);
        }
      case const (ExamDTO):
        {
          final exam = item as ExamDTO;
          itemName = exam.text;
          onRevert = () => ref.read(examProvider.notifier).revertDelete(exam);
        }
      case const (SubjectDTO):
        {
          final subject = item as SubjectDTO;
          itemName = subject.name;
          onRevert =
              () => ref.read(subjectsProvider.notifier).revertDelete(subject);
        }
    }

    showDialogAdaptive(
        context: context,
        title: Text('Recover?'),
        content: Text('Recover \'$itemName\'?'),
        actions: [
          adaptiveDialogButton(
            context: context,
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          adaptiveDialogButton(
              context: context,
              child: Text('Recover'),
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
        title: Text('Recently deleted'),
        actions: [
          IconButton(
            onPressed: () => showDialogAdaptive(
              context: context,
              title: Text('Recover'),
              content: Text(
                  'To recover something, tap on it and recover. After 7 days, it will be deleted forever. '),
              actions: [
                adaptiveDialogButton(
                  context: context,
                  child: Text('Close'),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
            icon: Icon(Icons.info_outline),
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
            case const (HomeworkDTO):
              {
                daysLeft = 7 +
                    (item as HomeworkDTO)
                        .timestamp
                        .toDate()
                        .difference(now)
                        .inDays;
                tile = HomeworkTile(
                  hw: item,
                  borderIfMissed: false,
                  onChangedCompletion: null,
                  onDelete: null,
                  onEdit: () => recover(context: context, ref: ref, item: item),
                  onConvert: null,
                );
              }
            case const (ExamDTO):
              {
                daysLeft = 7 +
                    (item as ExamDTO).timestamp.toDate().difference(now).inDays;
                tile = ExamTile(
                  exam: item,
                  onDelete: null,
                  onEdit: () => recover(context: context, ref: ref, item: item),
                  onConvert: null,
                );
              }
            case const (SubjectDTO):
              {
                daysLeft = 7 +
                    (item as SubjectDTO)
                        .timestamp
                        .toDate()
                        .difference(now)
                        .inDays;
                tile = SubjectTile(
                  subject: item,
                  onDelete: null,
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
                  '${daysLeft.toString()} day${daysLeft > 1 ? 's' : ''} left',
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
