import 'package:flutter/material.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
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
    required this.updateView,
  });

  final PageController pageController;
  final void Function(int)? onPageChanged;
  final int negativePageCount;

  final Map<DateTime, List<HomeworkDTO>> hwByDate;
  final Map<DateTime, List<ExamDTO>> examByDate;
  final List<HomeworkDTO> missedHwList;
  final bool showMissed;
  final void Function() updateView;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      itemBuilder: (context, pageIndex) {
        DateTime now = DateTime.now().toUtc();
        DateTime nowOnlyDate = DateTime.utc(now.year, now.month, now.day);
        int daysToAdd = pageIndex - negativePageCount;
        DateTime date = nowOnlyDate.add(Duration(days: daysToAdd));

        List<HomeworkDTO> hwListForDay = hwByDate[date] ?? [];
        List<ExamDTO> examListForDay = examByDate[date] ?? [];

        final bool showMissed =
            missedHwList.isNotEmpty && !date.isBeforeToday() && this.showMissed;

        return RescheduleDragTarget(
          currentDate: date,
          updateView: updateView,
          onMove: (details) {
            if (pageController.page?.round() != negativePageCount + daysToAdd) {
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
                                  draggable: true,
                                  hwList: missedHwList,
                                  updateListView: updateView,
                                )
                              ],
                            ),
                          ),
                        ),
                      ExamList(
                        showDates: false,
                        showText: true,
                        draggable: true,
                        examList: examListForDay,
                        updateView: updateView,
                      ),
                      HomeworkList(
                        showDates: false,
                        showText: true,
                        draggable: true,
                        hwList: hwListForDay,
                        updateListView: updateView,
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
                        color:
                            showOverlay ? scheme.primary.withAlpha(20) : null,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: showOverlay ? scheme.primary : scheme.surface,
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
    );
  }
}
