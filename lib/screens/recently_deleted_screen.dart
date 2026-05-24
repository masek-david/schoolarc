import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/screens/subjects/widgets/subject_tile.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/empty_message.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';
import 'package:schoolarc/widgets/tiles/exam_tile.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';

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
          onRevert = () =>
              ref.read(hwDataProvider.notifier).revertDelete(hw.toData());
        }
      case const (Exam):
        {
          final exam = item as Exam;
          itemName = exam.text;
          onRevert = () =>
              ref.read(examDataProvider.notifier).revertDelete(exam.toData());
        }
      case const (Subject):
        {
          final subject = item as Subject;
          itemName = subject.name;
          onRevert = () =>
              ref.read(subjectsProvider.notifier).revertDelete(subject);
        }
    }

    showMyDialog(
      context: context,
      title: '${context.loc.recover}?',
      text: '${context.loc.recover} \'$itemName\'?',
      actions: [
        DialogActionButton(
          text: context.loc.cancel,
          onPressed: () => Navigator.pop(context),
        ),
        DialogActionButton(
          text: context.loc.recover,
          isDefaultAction: true,
          onPressed: () {
            onRevert();
            Navigator.pop(context);
          },
        ),
      ],
    );
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
          IconButtonM3E(
            onPressed: () => showMyDialog(
              context: context,
              title: context.loc.recover,
              text: context.loc.recoverInfoContent,
              actions: [
                DialogActionButton(
                  text: context.loc.close,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            icon: const Icon(Icons.info_outline_rounded),
          ),
        ],
      ),
      body: items.isEmpty
          ? EmptyMessage(
              message: context.loc.noRecentlyDeleted,
            )
          : ListView.builder(
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
                          7 +
                          (item as Homework).timestamp.difference(now).inDays;
                      tile = HwTile(
                        hw: item,
                        showBorderIfMissed: false,
                        onChangedCompletion: null,
                        onDelete: null,
                        onEdit: () =>
                            recover(context: context, ref: ref, item: item),
                        onConvert: null,
                      );
                    }
                  case const (Exam):
                    {
                      daysLeft =
                          7 + (item as Exam).timestamp.difference(now).inDays;
                      tile = ExamTile(
                        exam: item,
                        onDelete: null,
                        onEdit: () =>
                            recover(context: context, ref: ref, item: item),
                        onConvert: null,
                      );
                    }
                  case const (Subject):
                    {
                      daysLeft =
                          7 +
                          (item as Subject).timestamp.difference(now).inDays;
                      tile = SubjectTile(
                        subject: item,
                        onDelete: kDebugMode
                            ? () {
                                subjectsDb.delete(item.id);
                                fireService.deleteSubjects([item]);
                              }
                            : null,
                        onTap: () =>
                            recover(context: context, ref: ref, item: item),
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
