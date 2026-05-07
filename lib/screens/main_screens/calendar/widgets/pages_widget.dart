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
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_refresh_indicator.dart';
import 'package:schoolarc/widgets/hold_drag_target.dart';
import 'package:schoolarc/widgets/lists/exam_list.dart';
import 'package:schoolarc/widgets/lists/homework_list.dart';
import 'package:schoolarc/widgets/lists/list_bottom_spacer.dart';
import 'package:schoolarc/widgets/text_actions.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';

class PagesWidget extends ConsumerWidget {
  const PagesWidget({
    super.key,
    required this.pageController,
    required this.onPageChanged,
    required this.hwByDate,
    required this.examByDate,
    required this.missedHws,
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

  final Map<Date, List<Homework>> hwByDate;
  final Map<Date, List<Exam>> examByDate;
  final List<Homework> missedHws;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final showMissed = ref.watch(calendarShowMissedProvider);

    return Stack(
      children: [
        Column(
          children: [
            if (missedHws.isNotEmpty && showMissed)
              TextActions(
                text:
                    '${context.loc.missedHomeworkTitle} (${missedHws.length})',
                color: context.col.error,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              ),
            Expanded(
              child: ClipRect(
                // There are two refresh indicators because this one works only before the seconds is assigned => just lazy fix
                child: ExpressiveRefreshIndicator(
                  onRefresh: () => refreshAll(context, ref),
                  child: NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) {
                      return showMissed && missedHws.isNotEmpty
                          ? [
                              SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  childCount: missedHws.length,
                                  (context, index) {
                                    final hw = missedHws[index];

                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        12,
                                        0,
                                        12,
                                        8,
                                      ),
                                      child: HwTile(
                                        draggable: true,
                                        hw: hw,
                                        onChangedCompletion: (completed) =>
                                            hwOnChangedCompletion(
                                              hw,
                                              completed,
                                            ),
                                        onDelete: () => hwOnDelete(hw),
                                        onEdit: () => hwOnEdit(hw),
                                        onConvert: () => hwOnConvert(hw),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ]
                          : [];
                    },
                    body: PageView.builder(
                      controller: pageController,
                      onPageChanged: onPageChanged,
                      itemBuilder: (context, daySinceEpoch) {
                        final date = Date.fromDaysSinceEpoch(daySinceEpoch);

                        List<Homework> hwListForDay = hwByDate[date] ?? [];
                        List<Exam> examListForDay = examByDate[date] ?? [];

                        return HoldDragTarget(
                          hoverStart: () {},
                          heldAction: () async {
                            if (pageController.page?.round() == daySinceEpoch) {
                              return;
                            }
                            vibrate.medium();
                            await pageController.animateToPage(
                              daySinceEpoch,
                              duration: Durations.medium2,
                              curve: Curves.decelerate,
                            );
                          },
                          onAcceptWithDetails: (details) async {
                            if (details.data.runtimeType == Homework) {
                              final hw = details.data as Homework;
                              if (!hw.date.isSameDay(date)) {
                                ref
                                    .read(hwDataProvider.notifier)
                                    .update(
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
                                ref
                                    .read(examDataProvider.notifier)
                                    .update(
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Stack(
                                children: [
                                  ExpressiveRefreshIndicator(
                                    onRefresh: () => refreshAll(context, ref),
                                    child: ListView(
                                      primary:
                                          pageController.page?.round() ==
                                          daySinceEpoch,
                                      children: [
                                        ExamList(
                                          examList: examListForDay,
                                          onEdit: examOnEdit,
                                          onDelete: examOnDelete,
                                          onConvert: examOnConvert,
                                          showDates: false,
                                          draggable: true,
                                          text: context.loc.examAbsence(
                                            examListForDay.isEmpty.toString(),
                                          ),
                                        ),
                                        HomeworkList(
                                          hwList: hwListForDay,
                                          onChangedCompletion:
                                              hwOnChangedCompletion,
                                          onDelete: hwOnDelete,
                                          onEdit: hwOnEdit,
                                          onConvert: hwOnConvert,
                                          showDates: false,
                                          draggable: true,
                                          text: context.loc.homeworkAbsence(
                                            hwListForDay.isEmpty.toString(),
                                          ),
                                        ),
                                        const ListBottomSpacer(),
                                        const ListBottomSpacer(),
                                      ],
                                    ),
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
                                                      fontWeight:
                                                          FontWeight.bold,
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
                  ),
                ),
              ),
            ),
          ],
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
