import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/pages_widget.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/scrollable_calendar.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/week_calendar.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/intent/intents.dart';
import 'package:schoolarc/utils/task_functions.dart';
import 'package:schoolarc/widgets/web_request_focus.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

final _minimumColumnWidth = 350.0;

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({
    super.key,
    this.initialDate,
  });

  final Date? initialDate;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with RestorationMixin {
  late final showTomorrow = ref.read(calendarInitialIsTomorrowProvider);

  late final _selectedDate = RestorableDate(
    widget.initialDate ??
        (showTomorrow ? Date.today().addDays(1) : Date.today()),
  );
  late final _focusedDate = RestorableDate(_selectedDate.value);

  final _pagesKey = GlobalKey();
  late final _pageController = PageController(
    viewportFraction: 0.90,
    initialPage: _selectedDate.value.daysSinceEpoch,
  );
  late final _monthCalendarController = ItemScrollController();
  late final _weekCalendarController = PageController(
    initialPage: _selectedDate.value.weekSinceEpoch,
  );

  final _resizeController = ResizableController();
  var initialRatios = List<double>.from(
    settings.get(Setting.calendarResizableContainerRatio),
  );

  final _focus = FocusNode(); // for shorcuts

  @override
  void initState() {
    super.initState();

    _resizeController.addListener(
      () {
        settings.save(
          Setting.calendarResizableContainerRatio,
          _resizeController.ratios.toList(),
        );
      },
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => _focus.requestFocus(),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _weekCalendarController.dispose();
    _focus.dispose();
    _selectedDate.dispose();

    super.dispose();
  }

  @override
  String? get restorationId => 'calendar';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selectedDate');
    registerForRestoration(_focusedDate, 'focusedDate');
  }

  /// if the selectedDay is already set, it skips
  ///
  /// [scrollPage] is false when calling from pages widget, so the page isnt scrolled
  ///
  /// [scrollCalendar] is false when calling from calendar widget, so the calendar isnt scrolled
  void setSelectedDate(
    Date date, {
    bool scrollPage = true,
    bool scrollCalendar = true,
  }) {
    if (_selectedDate.value == date) {
      return;
    }
    vibrate.light();
    setState(() {
      _selectedDate.value = date;
      _focusedDate.value = date;
    });

    if (!mounted) return;
    if (scrollPage) {
      final pageDiff = date.daysSinceEpoch - _pageController.page!;
      if (pageDiff.abs() <= 1) {
        _pageController.animateToPage(
          date.daysSinceEpoch,
          duration: Durations.medium2,
          curve: Curves.decelerate,
        );
      } else {
        _pageController.jumpToPage(date.daysSinceEpoch);
      }
    }
    if (scrollCalendar) {
      if (_monthCalendarController.isAttached) {
        _monthCalendarController.scrollTo(
          index: date.weekSinceEpoch - 1,
          duration: Durations.medium2,
        );
      }
      // _weekCalendarController.jumpTo(date.weekSinceEpoch.toDouble());
      if (_weekCalendarController.hasClients) {
        _weekCalendarController.animateToPage(
          date.weekSinceEpoch,
          duration: Durations.medium2,
          curve: Curves.decelerate,
        );
      }
    }
  }

  Widget buildPages(
    Map<Date, List<Homework>> hws,
    Map<Date, List<Exam>> exams,
    List<Homework> missedHws,
  ) {
    return PagesWidget(
      key: _pagesKey,
      examOnDelete: (exam) => deleteExam(context, ref, exam),
      examOnEdit: (exam) => editExam(context, exam),
      examOnConvert: (exam) => convertExam(context, ref, exam),
      hwOnChangedCompletion: (hw, value) => completeHw(context, ref, hw, value),
      hwOnDelete: (hw) => deleteHw(context, ref, hw),
      hwOnEdit: (hw) => editHw(context, hw),
      hwOnConvert: (hw) => convertHw(context, ref, hw),
      pageController: _pageController,
      onPageChanged: (page) =>
          setSelectedDate(Date.fromDaysSinceEpoch(page), scrollPage: false),
      hwByDate: hws,
      examByDate: exams,
      missedHws: missedHws,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hws = ref.watch(hwDatesProvider);
    final missedHws = ref.watch(hwMissedProvider);
    final exams = ref.watch(examsDatesProvider);

    final isWide =
        MediaQuery.sizeOf(context).width > _minimumColumnWidth * 2 + 28 + 84;
    final pagesWidget = buildPages(hws, exams, missedHws);

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyH):
            const NewHomeworkIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE):
            const NewExamIntent(),
      },
      child: Actions(
        actions: {
          NewHomeworkIntent: CallbackAction(
            onInvoke: (intent) => addNewHw(
              context,
              initialDate: _selectedDate.value,
            ),
          ),
          NewExamIntent: CallbackAction(
            onInvoke: (intent) => addNewExam(
              context,
              initialDate: _selectedDate.value,
            ),
          ),
        },
        child: Focus(
          focusNode: _focus,
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: Scaffold(
              floatingActionButton: WebRequestFocusBuilder(
                builder: (showKeyboard) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      FloatingActionButton.extended(
                        tooltip:
                            '${context.loc.addNewExamFor} ${_selectedDate.value.formatWithText(context).toLowerCase()}',
                        heroTag: 'exam_btn',
                        onPressed: () {
                          showKeyboard();
                          vibrate.medium();
                          addNewExam(context, initialDate: _selectedDate.value);
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: Text(context.loc.exams(1)),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton.extended(
                        tooltip:
                            '${context.loc.addNewHomeworkFor} ${_selectedDate.value.formatWithText(context).toLowerCase()}',
                        heroTag: 'homework_btn',
                        onPressed: () {
                          showKeyboard();
                          vibrate.medium();
                          addNewHw(context, initialDate: _selectedDate.value);
                        },
                        icon: const Icon(Icons.add_rounded),
                        label: Text(context.loc.homework(1)),
                      ),
                    ],
                  );
                },
              ),
              body: isWide
                  ? Container(
                      // this is what is shown behind the resizable container divider
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // if the screen was big, but now is small, it wouldnt fit, so i check it here and reset it if needed
                          for (var element in initialRatios) {
                            if (element * constraints.maxWidth <
                                _minimumColumnWidth) {
                              initialRatios = [0.5, 0.5];
                            }
                          }
    
                          if (initialRatios.first + initialRatios.last >
                              1.001) {
                            initialRatios = [0.5, 0.5];
                          }
    
                          return ResizableContainer(
                            controller: _resizeController,
                            direction: Axis.horizontal,
                            children: [
                              ResizableChild(
                                size: ResizableSize.ratio(
                                  initialRatios[0],
                                  min: _minimumColumnWidth,
                                ),
                                divider: const ResizableDivider(
                                  thickness: 4,
                                  length: ResizableSize.pixels(60),
                                  padding: 12,
                                ),
                                child: ScrollableCalendar(
                                  controller: _monthCalendarController,
                                  onExamTap: (exam) =>
                                      editExam(context, exam),
                                  homeworks: hws,
                                  exams: exams,
                                  selectedDate: _selectedDate.value,
                                  onTitleTap: () =>
                                      setSelectedDate(Date.today()),
                                  onDateSelected: (selectedDate) =>
                                      setSelectedDate(
                                        selectedDate,
                                        scrollCalendar: false,
                                      ),
                                ),
                              ),
                              ResizableChild(
                                size: ResizableSize.ratio(
                                  initialRatios[1],
                                  min: _minimumColumnWidth,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                  ),
                                  child: pagesWidget,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : Column(
                      children: [
                        SizedBox(height: MediaQuery.viewPaddingOf(context).top + 24),
                        WeekCalendar(
                          controller: _weekCalendarController,
                          selectedDate: _selectedDate.value,
                          setSelectedDate: (date) =>
                              setSelectedDate(date, scrollCalendar: false),
                          homeworks: hws,
                          exams: exams,
                          examOnEdit: (exam) => editExam(context, exam),
                        ),
                        Expanded(child: pagesWidget),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
