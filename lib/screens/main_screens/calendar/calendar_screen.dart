import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_resizable_container/flutter_resizable_container.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/use_cloudsync_notifier.dart';
import 'package:schoolarc/screens/current_timetable/loading_icon_button.dart';
import 'package:schoolarc/screens/main_screens/calendar/calendar_settings.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/calendar_widget.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/pages_widget.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/intent/intents.dart';
import 'package:schoolarc/utils/task_functions.dart';
import 'package:schoolarc/widgets/wide_screen_app_bar.dart';
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

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  late DateTime _selectedDay = _focusedDay;

  // how many pages you can scroll to negative
  static const int negativePageCount = 1000000;
  late final showtomorrow =
      ref.read(calendarInitialIsTomorrowProvider) || widget.showtomorrow;
  late final PageController _pageController = PageController(
    viewportFraction: 0.90,
    initialPage: negativePageCount + (showtomorrow ? 1 : 0),
  );

  final _resizeController = ResizableController();
  final List<double> initialRatios =
      List<double>.from(settings.get(Setting.calendarResizableContainerRatio));

  // for shorcuts
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (showtomorrow) {
      _focusedDay =
          DateTime.now().toUtc().add(const Duration(days: 1)).toLocal();
      _selectedDay = _focusedDay;
    }

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

    super.dispose();
  }

  Widget buildCalendar(
    bool isWide,
    Map<DateTime, List<Homework>> hws,
    Map<DateTime, List<Exam>> exams,
  ) {
    return CalendarWidget(
      onEdit: (exam) => editExam(context, ref, exam),
      focusedDay: _focusedDay,
      selectedDay: _selectedDay,
      negativePageCount: negativePageCount,
      setFocusedDay: (date) {
        if (mounted) {
          setState(() {
            _focusedDay = date;
          });
        }
      },
      calendarFormat: isWide ? CalendarFormat.month : CalendarFormat.week,
      homeworks: hws,
      exams: exams,
      jumpToPage: (page) {
        _pageController.jumpToPage(page);
      },
      onHeaderTapped: (date) {
        setState(() {
          _focusedDay = DateTime.now();
        });
        _pageController.jumpToPage(negativePageCount);
      },
      onFormatChanged: (format) {},
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
    );
  }

  Widget buildPages(
    Map<DateTime, List<Homework>> hws,
    Map<DateTime, List<Exam>> exams,
    List<Homework> missedHw,
  ) {
    return PagesWidget(
      examOnDelete: (exam) => deleteExam(context, ref, exam),
      examOnEdit: (exam) => editExam(context, ref, exam),
      examOnConvert: (exam) => convertExam(context, ref, exam),
      hwOnChangedCompletion: (hw, value) => completeHw(context, ref, hw, value),
      hwOnDelete: (hw) => deleteHw(context, ref, hw),
      hwOnEdit: (hw) => editHw(context, ref, hw),
      hwOnConvert: (hw) => convertHw(context, ref, hw),
      pageController: _pageController,
      onPageChanged: (page) {
        setState(() {
          _focusedDay = DateTime.now()
              .toUtc()
              .add(Duration(days: page - negativePageCount))
              .toLocal();
          _selectedDay = _focusedDay;
        });
      },
      negativePageCount: negativePageCount,
      hwByDate: hws,
      examByDate: exams,
      missedHwList: missedHw,
    );
  }

  PreferredSizeWidget buildAppBar(bool isWide) {
    return WideScreenAppBar(
      isWideScreen: isWide,
      title: Text(context.loc.calendar),
      actions: [
        if (ref.watch(useCloudSyncProvider))
          LoadingIconButton(
            icon: Icons.refresh,
            onTap: () async {
              try {
                await syncAllTasks(ref);
              } on Object catch (e) {
                if (mounted) {
                  showMessage(context, e.toString(), isError: true);
                }
                return;
              }
            },
          ),
        IconButton(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) => const CalendarSettings(),
            );
          },
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hws = ref.watch(hwDatesProvider);
    final missedHws = ref.watch(hwMissedProvider);
    final exams = ref.watch(examsDatesProvider);

    final isWide = context.isWide;

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
            onInvoke: (intent) =>
                addNewHw(context, ref, initialDate: _selectedDay),
          ),
          NewExamIntent: CallbackAction(
            onInvoke: (intent) =>
                addNewExam(context, ref, initialDate: _selectedDay),
          ),
        },
        child: Focus(
          focusNode: _focus,
          child: MediaQuery.removePadding(
            // the padding doesnt need to exist anymore, the fabs would be too high
            context: context,
            removeBottom: true,
            child: Scaffold(
              appBar: isWide ? null : buildAppBar(isWide),
              floatingActionButton: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    tooltip:
                        '${context.loc.addNewExamFor} ${_selectedDay.dateText().toLowerCase()}',
                    heroTag: 'exam_btn',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      addNewExam(context, ref, initialDate: _selectedDay);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(context.loc.exams(1)),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.extended(
                    tooltip:
                        '${context.loc.addNewHomeworkFor} ${_selectedDay.dateText().toLowerCase()}',
                    heroTag: 'homework_btn',
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      addNewHw(context, ref, initialDate: _selectedDay);
                    },
                    icon: const Icon(Icons.add),
                    label: Text(context.loc.homeworks(1)),
                  ),
                ],
              ),
              body: isWide
                  ? Container(
                      // this is what is shown behind the resizable container
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      child: ResizableContainer(
                        controller: _resizeController,
                        direction: Axis.horizontal,
                        children: [
                          ResizableChild(
                            size:
                                ResizableSize.ratio(initialRatios[0], min: 300),
                            divider: const ResizableDivider(
                              thickness: 4,
                              length: ResizableSize.pixels(60),
                              padding: 12,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Scaffold(
                                appBar: buildAppBar(isWide),
                                body: buildCalendar(isWide, hws, exams),
                              ),
                            ),
                          ),
                          ResizableChild(
                            size:
                                ResizableSize.ratio(initialRatios[1], min: 300),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              child: buildPages(hws, exams, missedHws),
                            ),
                          ),
                        ],
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
