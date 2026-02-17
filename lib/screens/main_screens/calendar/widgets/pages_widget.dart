import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/arrow_buttons_row.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/widgets/hold_drag_target.dart';
import 'package:schoolarc/widgets/lists/exam_list.dart';
import 'package:schoolarc/widgets/lists/homework_list.dart';
import 'package:schoolarc/widgets/lists/list_bottom_spacer.dart';
import 'package:schoolarc/widgets/lists/title_with_count.dart';

class PagesWidget extends ConsumerWidget {
  const PagesWidget({
    super.key,
    required this.pageController,
    required this.onPageChanged,
    required this.negativePageCount,
    required this.hwByDate,
    required this.examByDate,
    required this.missedHwList,
    required this.examOnDelete,
    required this.examOnEdit,
    required this.hwOnEdit,
    required this.hwOnDelete,
    required this.hwOnChangedCompletion,
    required this.hwOnConvert,
    required this.examOnConvert,
  });

  final void Function(Exam exam) examOnDelete;
  final void Function(Exam exam) examOnEdit;
  final void Function(Exam exam) examOnConvert;
  final void Function(Homework hw) hwOnEdit;
  final void Function(Homework hw) hwOnDelete;
  final void Function(Homework hw) hwOnConvert;
  final void Function(Homework hw, bool value) hwOnChangedCompletion;

  final PageController pageController;
  final void Function(int) onPageChanged;
  final int negativePageCount;

  final Map<Date, List<Homework>> hwByDate;
  final Map<Date, List<Exam>> examByDate;
  final List<Homework> missedHwList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final settingShowMissed = ref.watch(calendarShowMissedProvider);

    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          onPageChanged: onPageChanged,
          itemBuilder: (context, pageIndex) {
            final daysToAdd = pageIndex - negativePageCount;
            final date = Date.today().addDays(daysToAdd);

            List<Homework> hwListForDay = hwByDate[date] ?? [];
            List<Exam> examListForDay = examByDate[date] ?? [];

            final bool showMissed = missedHwList.isNotEmpty &&
                !date.isBefore(Date.today()) &&
                settingShowMissed;

            return HoldDragTarget(
              heldAction: () {
                if (pageController.page?.round() !=
                    negativePageCount + daysToAdd) {
                  pageController.animateToPage(
                    negativePageCount + daysToAdd,
                    duration: Durations.medium3,
                    curve: Curves.easeInOut,
                  );
                }
              },
              onAcceptWithDetails: (details) async {
                if (details.data.runtimeType == Homework) {
                  final hw = details.data as Homework;
                  if (!hw.date.isSameDay(date)) {
                    ref.read(hwDataProvider.notifier).update(
                          hw.toData().copyWith(
                                date: date,
                                timestamp: DateTime.now().toUtc(),
                              ),
                        );
                  }
                }
                if (details.data.runtimeType == Exam) {
                  final exam = details.data as Exam;
                  if (!exam.date.isSameDay(date)) {
                    ref.read(examDataProvider.notifier).update(
                          exam.toData().copyWith(
                                date: date,
                                timestamp: DateTime.now().toUtc(),
                              ),
                        );
                  }
                }
              },
              builder: (context, candidateData, rejectedData) {
                bool showOverlay = candidateData.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Stack(
                    children: [
                      ListView(
                        children: [
                          if (showMissed)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: ListTileTheme(
                                contentPadding:
                                    const EdgeInsets.only(left: 4, right: 8),
                                child: ExpansionTile(
                                  initiallyExpanded: true,
                                  collapsedShape: const Border(),
                                  shape: const Border(),
                                  dense: true,
                                  title: TitleWithCount(
                                    text: context.loc.missedHomeworkTitle,
                                    textColor: scheme.error,
                                    countContainerColor:
                                        context.col.errorContainer,
                                    count: missedHwList.length,
                                  ),
                                  children: [
                                    HomeworkList(
                                      hwList: missedHwList,
                                      onChangedCompletion:
                                          hwOnChangedCompletion,
                                      onDelete: hwOnDelete,
                                      onConvert: hwOnConvert,
                                      onEdit: hwOnEdit,
                                      draggable: true,
                                      text: null,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ExamList(
                            examList: examListForDay,
                            onEdit: examOnEdit,
                            onDelete: examOnDelete,
                            onConvert: examOnConvert,
                            showDates: false,
                            draggable: true,
                            text: context.loc
                                .examAbsence(examListForDay.isEmpty.toString()),
                          ),
                          HomeworkList(
                            hwList: hwListForDay,
                            onChangedCompletion: hwOnChangedCompletion,
                            onDelete: hwOnDelete,
                            onEdit: hwOnEdit,
                            onConvert: hwOnConvert,
                            showDates: false,
                            draggable: true,
                            text: context.loc.homeworkAbsence(
                                hwListForDay.isEmpty.toString()),
                          ),
                          const ListBottomSpacer(),
                          const ListBottomSpacer(),
                        ],
                      ),
                      IgnorePointer(
                        child: AnimatedContainer(
                          duration: Durations.short3,
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: showOverlay
                                ? scheme.primary.withAlpha(20)
                                : null,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: showOverlay
                                  ? scheme.primary
                                  : Colors.transparent,
                              width: showOverlay ? 4 : 0,
                            ),
                          ),
                          child: showOverlay
                              ? Center(
                                  child: Text(
                                    '${context.loc.changeDateTo} ${date.formatFromSettings(context)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                )
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        if (ref.watch(calendarShowArrowsProvider))
          Align(
            alignment: Alignment.center,
            child: ArrowButtonsRow(
              onPressedLeft: () {
                pageController.previousPage(
                  duration: Durations.medium2,
                  curve: Curves.easeInOut,
                );
              },
              onPressedRight: () {
                pageController.nextPage(
                  duration: Durations.medium2,
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
      ],
    );
  }
}
