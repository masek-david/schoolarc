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
import 'package:schoolarc/screens/main_screens/calendar/widgets/calendar_widget.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/pages_widget.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/intent/intents.dart';
import 'package:schoolarc/utils/task_functions.dart';
import 'package:schoolarc/widgets/web_request_focus.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({
    super.key,
    this.showtomorrow = false,
  });

  final bool showtomorrow;

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with RestorationMixin {
  late final RestorableDateTime _focusedDay = RestorableDateTime(
    showtomorrow
        ? DateTime.now().toUtc().add(const Duration(days: 1)).toLocal()
        : DateTime.now(),
  );
  late final RestorableDateTime _selectedDay = RestorableDateTime(
    _focusedDay.value,
  );

  // how many pages you can scroll to negative
  static const int negativePageCount = 1000000;
  late final showtomorrow =
      ref.read(calendarInitialIsTomorrowProvider) || widget.showtomorrow;
  late final PageController _pageController = PageController(
    viewportFraction: 0.90,
    initialPage: getPageIndex(_selectedDay.value),
  );

  final _resizeController = ResizableController();
  List<double> initialRatios = List<double>.from(
    settings.get(Setting.calendarResizableContainerRatio),
  );

  // for shorcuts
  final _focus = FocusNode();

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
    _focus.dispose();
    _focusedDay.dispose();
    _selectedDay.dispose();

    super.dispose();
  }

  @override
  String? get restorationId => 'calendar';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_focusedDay, 'focusedDay');
    registerForRestoration(_selectedDay, 'selectedDay');
  }

  int getPageIndex(DateTime date) {
    final now = DateTime.now();
    final nowOnlyDay = DateTime(now.year, now.month, now.day);
    final dateOnlyDay = DateTime(date.year, date.month, date.day);
    final dayDifferenceFromNow = dateOnlyDay.difference(nowOnlyDay).inDays;
    return negativePageCount + dayDifferenceFromNow;
  }

  Widget buildCalendar(
    bool isWide,
    Map<Date, List<Homework>> hws,
    Map<Date, List<Exam>> exams,
  ) {
    return CalendarWidget(
      focusedDay: _focusedDay.value,
      selectedDay: _selectedDay.value,
      homeworks: hws,
      exams: exams,
      calendarFormat: isWide ? CalendarFormat.month : CalendarFormat.week,
      onEdit: (exam) => editExam(context, exam),
      setFocusedDay: (date) {
        setState(() {
          _focusedDay.value = date;
        });
      },
      setSelectedDay: (date) {
        if (!mounted) return;
        if (!isSameDay(date, _selectedDay.value)) {
          _pageController.jumpToPage(getPageIndex(date));
        }
      },
    );
  }

  Widget buildPages(
    Map<Date, List<Homework>> hws,
    Map<Date, List<Exam>> exams,
    List<Homework> missedHw,
  ) {
    return PagesWidget(
      examOnDelete: (exam) => deleteExam(context, ref, exam),
      examOnEdit: (exam) => editExam(context, exam),
      examOnConvert: (exam) => convertExam(context, ref, exam),
      hwOnChangedCompletion: (hw, value) => completeHw(context, ref, hw, value),
      hwOnDelete: (hw) => deleteHw(context, ref, hw),
      hwOnEdit: (hw) => editHw(context, hw),
      hwOnConvert: (hw) => convertHw(context, ref, hw),
      pageController: _pageController,
      onPageChanged: (page) {
        if (!mounted) return;
        setState(() {
          _focusedDay.value = DateTime.now()
              .toUtc()
              .add(Duration(days: page - negativePageCount))
              .toLocal();
          _selectedDay.value = _focusedDay.value;
        });
      },
      negativePageCount: negativePageCount,
      hwByDate: hws,
      examByDate: exams,
      missedHwList: missedHw,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hws = ref.watch(hwDatesProvider);
    final missedHws = ref.watch(hwMissedProvider);
    final exams = ref.watch(examsDatesProvider);

    final isWide = MediaQuery.of(context).size.width > 750;

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
              initialDate: Date.fromDateTime(_selectedDay.value.toLocal()),
            ),
          ),
          NewExamIntent: CallbackAction(
            onInvoke: (intent) => addNewExam(
              context,
              initialDate: Date.fromDateTime(_selectedDay.value.toLocal()),
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
                            '${context.loc.addNewExamFor} ${Date.fromDateTime(_selectedDay.value).formatWithText(context).toLowerCase()}',
                        heroTag: 'exam_btn',
                        onPressed: () {
                          showKeyboard();
                          vibrate.medium();
                          addNewExam(
                            context,
                            initialDate: Date.fromDateTime(
                              _selectedDay.value.toLocal(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: Text(context.loc.exams(1)),
                      ),
                      const SizedBox(height: 10),
                      FloatingActionButton.extended(
                        tooltip:
                            '${context.loc.addNewHomeworkFor} ${Date.fromDateTime(_selectedDay.value).formatWithText(context).toLowerCase()}',
                        heroTag: 'homework_btn',
                        onPressed: () {
                          showKeyboard();
                          vibrate.medium();
                          addNewHw(
                            context,
                            initialDate: Date.fromDateTime(
                              _selectedDay.value.toLocal(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add),
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
                            if (element * constraints.maxWidth < 300) {
                              initialRatios = [0.5, 0.5];
                            }
                          }

                          return ResizableContainer(
                            controller: _resizeController,
                            direction: Axis.horizontal,
                            children: [
                              ResizableChild(
                                size: ResizableSize.ratio(
                                  initialRatios[0],
                                  min: 300,
                                ),
                                // size: const ResizableSize.expand(min: 300),
                                divider: const ResizableDivider(
                                  thickness: 4,
                                  length: ResizableSize.pixels(60),
                                  padding: 12,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: buildCalendar(isWide, hws, exams),
                                ),
                              ),
                              ResizableChild(
                                // size: const ResizableSize.expand(min: 300),
                                size: ResizableSize.ratio(
                                  initialRatios[1],
                                  min: 300,
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                  ),
                                  child: buildPages(hws, exams, missedHws),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    )
                  : Column(
                      children: [
                        buildCalendar(isWide, hws, exams),
                        const SizedBox(height: 4),
                        Expanded(child: buildPages(hws, exams, missedHws)),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
