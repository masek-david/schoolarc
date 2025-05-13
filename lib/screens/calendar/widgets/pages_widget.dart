import 'package:flutter/material.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/screens/calendar/widgets/arrow_buttons_row.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/widgets/exam_list.dart';
import 'package:school_manager/widgets/expansion_title.dart';
import 'package:school_manager/widgets/homework_list.dart';
import 'package:school_manager/widgets/list_bottom_spacer.dart';
import 'package:school_manager/widgets/reschedule_drag_target.dart';

class PagesWidget extends StatelessWidget {
  const PagesWidget({
    super.key,
    required this.pageController,
    required this.onPageChanged,
    required this.negativePageCount,
    required this.hwByDate,
    required this.examByDate,
    required this.missedHwList,
    required this.showMissed,
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

  final Map<DateTime, List<Homework>> hwByDate;
  final Map<DateTime, List<Exam>> examByDate;
  final List<Homework> missedHwList;
  final bool showMissed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        PageView.builder(
          controller: pageController,
          onPageChanged: onPageChanged,
          itemBuilder: (context, pageIndex) {
            final now = DateTime.now().toUtc();
            final nowOnlyDate = DateTime.utc(now.year, now.month, now.day);
            final daysToAdd = pageIndex - negativePageCount;
            final dateUtc = nowOnlyDate.add(Duration(days: daysToAdd));
            final date = DateTime(dateUtc.year, dateUtc.month, dateUtc.day);

            List<Homework> hwListForDay = hwByDate[date] ?? [];
            List<Exam> examListForDay = examByDate[date] ?? [];

            final bool showMissed = missedHwList.isNotEmpty &&
                !date.isBeforeToday() &&
                this.showMissed;

            return RescheduleDragTarget(
              currentDate: date,
              onMove: (details) {
                if (pageController.page?.round() !=
                    negativePageCount + daysToAdd) {
                  pageController.animateToPage(
                    negativePageCount + daysToAdd,
                    duration: Durations.long2,
                    curve: Curves.easeInOut,
                  );
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
                                  title: ExpansionTitle(
                                    titleText: 'Missed Homeworks',
                                    boldText: false,
                                    titleTextColor: scheme.error,
                                    numberOfItems: missedHwList.length,
                                  ),
                                  children: [
                                    HomeworkList(
                                      onChangedCompletion:
                                          hwOnChangedCompletion,
                                      onDelete: hwOnDelete,
                                      onConvert: hwOnConvert,
                                      onEdit: hwOnEdit,
                                      draggable: true,
                                      hwList: missedHwList,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ExamList(
                            onEdit: examOnEdit,
                            onDelete: examOnDelete,
                            onConvert: examOnConvert,
                            showDates: false,
                            showText: true,
                            draggable: true,
                            examList: examListForDay,
                          ),
                          HomeworkList(
                            onChangedCompletion: hwOnChangedCompletion,
                            onDelete: hwOnDelete,
                            onEdit: hwOnEdit,
                            onConvert: hwOnConvert,
                            showDates: false,
                            showText: true,
                            draggable: true,
                            hwList: hwListForDay,
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
                                    'Change date to ${date.formattedDate()}',
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
        if(settings.get(Setting.calendarShowArrows))
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
