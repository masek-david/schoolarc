import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/m3e/buttons/button_m3e.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/screens/recap/recap_count_page.dart';
import 'package:schoolarc/screens/recap/recap_days_page.dart';
import 'package:schoolarc/screens/recap/recap_end_page.dart';
import 'package:schoolarc/screens/recap/recap_priority_page.dart';
import 'package:schoolarc/screens/recap/recap_subjects_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/animated_shape.dart';

class RecapData {
  RecapData({
    required this.name,
    required this.year,
    required this.homeworksCount,
    required this.examsCount,
    required this.days,
    required this.priorities,
    required this.subjects,
  });

  final String name;
  final String year;
  final int homeworksCount;
  final int examsCount;
  final List<int> days;
  final List<int> priorities;
  final List<SubjectWithUsedTimes> subjects;

  factory RecapData.generate({
    required String name,
    required String year,
    required List<Homework> hws,
    required List<Exam> exams,
  }) {
    // GENERATE DAYS
    final days = List.generate(7, (index) => 0);
    for (final hw in hws) {
      days[hw.date.weekday - 1]++;
    }
    for (final exam in exams) {
      days[exam.date.weekday - 1]++;
    }

    // GENERATE PRIORITIES
    final priorities = List.generate(4, (index) => 0);
    for (final hw in hws) {
      priorities[hw.priority.index]++;
    }
    for (final exam in exams) {
      priorities[exam.priority.index]++;
    }

    // GENERATE SUBJECTS
    final Map<Subject, int> subjectsMap = {};
    for (final hw in hws) {
      if (hw.subject != null) {
        subjectsMap[hw.subject!] = (subjectsMap[hw.subject] ?? 0) + 1;
      }
    }
    for (final exam in exams) {
      if (exam.subject != null) {
        subjectsMap[exam.subject!] = (subjectsMap[exam.subject] ?? 0) + 1;
      }
    }
    final subjects = subjectsMap.entries
        .map((e) => SubjectWithUsedTimes(subject: e.key, usedTimes: e.value))
        .toList();

    subjects.sort(
      (a, b) => b.usedTimes.compareTo(a.usedTimes),
    );

    return RecapData(
      name: name,
      year: year,
      homeworksCount: hws.length,
      examsCount: exams.length,
      days: days,
      priorities: priorities,
      subjects: subjects,
    );
  }

  /// start with 'sti$version', encodes the name, year, hwcount, examcount, subjects - pair of shortcut and count, 7 days, and 4 priorities
  String encode() {
    // sti0<GS>David<GS>159<GS>101<GS>Čjl<RS>45<US>Ma<RS>38<US>Fy<RS>27<GS>45<RS>43<RS>46<RS>49<RS>72<RS>2<RS>3<GS>55<RS>52<RS>101<RS>52
    return 'sti0\x1D'
        '$name\x1D'
        '$homeworksCount\x1D'
        '$examsCount\x1D'
        '${subjects.take(3).map(
          (e) => '${e.subject.shortcut}\x1E${e.usedTimes}',
        ).join('\x1F')}\x1D'
        '${days.join('\x1E')}\x1D'
        '${priorities.join('\x1E')}';
  }

  // TODO test
  factory RecapData.decode(String input) {
    final input =
        'sti0<GS>David<GS>159<GS>101<GS>Čjl<RS>45<US>Ma<RS>38<US>Fy<RS>27<GS>45<RS>43<RS>46<RS>49<RS>72<RS>2<RS>3<GS>55<RS>52<RS>101<RS>52';
    const gs = '\x1D';
    const rs = '\x1F';
    const us = '\x1E';

    final parts = input.split(gs);

    if (parts.length < 6 || !parts[0].startsWith('sti')) {
      throw const FormatException('Invalid format');
    }

    final name = parts[1];
    final homeworksCount = int.parse(parts[2]);
    final examsCount = int.parse(parts[3]);

    // -------------------------
    // SUBJECTS
    // -------------------------
    final subjectsRaw = parts[4];
    final subjects = <SubjectWithUsedTimes>[];

    if (subjectsRaw.isNotEmpty) {
      final subjectEntries = subjectsRaw.split(rs);

      for (final entry in subjectEntries) {
        final pair = entry.split(us);
        if (pair.length != 2) continue;

        subjects.add(
          SubjectWithUsedTimes(
            subject: Subject(
              name: '',
              shortcut: pair[0],
              id: '',
              bakaId: '',
              timestamp: DateTime.now(),
              isDeleted: false,
              order: 0,
            ),
            usedTimes: int.parse(pair[1]),
          ),
        );
      }
    }

    // -------------------------
    // DAYS
    // -------------------------
    final daysRaw = parts[5];
    final days = daysRaw.isEmpty
        ? <int>[]
        : daysRaw.split(us).map(int.parse).toList();

    // -------------------------
    // PRIORITIES
    // -------------------------
    final prioritiesRaw = parts.length > 6 ? parts[6] : '';
    final priorities = prioritiesRaw.isEmpty
        ? <int>[]
        : prioritiesRaw.split(us).map(int.parse).toList();

    final year = switch (parts[0]) {
      'sti0' => '2025-26',
      _ => '',
    };

    return RecapData(
      year: year,
      name: name,
      homeworksCount: homeworksCount,
      examsCount: examsCount,
      subjects: subjects,
      days: days,
      priorities: priorities,
    );
  }
}

class SubjectWithUsedTimes {
  SubjectWithUsedTimes({
    required this.usedTimes,
    required this.subject,
  });

  final Subject subject;
  final int usedTimes;
}

bool hasSeenRecap() {
  return settings.get(Setting.recapShownForYear) >= DateTime.now().year;
}

// returns true if it is last two weeks of school
bool isRecapDate() {
  final now = DateTime.now();

  return now.isAfter(now.copyWith(month: 6, day: 23)) &&
      now.isBefore(
        now.copyWith(month: 7, day: 8),
      );
}

// works only if the school year started last year
bool isInThisSchoolYear(Date date) {
  final today = Date.today();
  return date.isAfter(Date(today.year - 1, 8, 31)) &&
      date.isBefore(Date(today.year, 7, 8));
}

class RecapScreen extends ConsumerStatefulWidget {
  const RecapScreen({super.key});

  @override
  ConsumerState<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends ConsumerState<RecapScreen> {
  final _controller = PageController();

  void next() {
    _controller.nextPage(
      duration: SpatialMotion.slow.duration,
      curve: SpatialMotion.slow.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final hws = ref
        .watch(hwProvider)
        .values
        .where(
          (element) => isInThisSchoolYear(element.date) && !element.isDeleted,
        )
        .toList();
    final exams = ref
        .watch(examProvider)
        .values
        .where(
          (element) => isInThisSchoolYear(element.date) && !element.isDeleted,
        )
        .toList();

    final isDark = context.isDark;

    final recapData = RecapData.generate(
      exams: exams,
      hws: hws,
      name: 'David',
      year: '2025-26',
    );

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          leading: Align(
            alignment: .center,
            child: ButtonM3E.text(
              onPressed: () => Navigator.pop(context),
              child: Text(context.loc.exit),
            ),
          ),
          actions: kDebugMode
              ? [
                  IconButtonM3E(
                    icon: const Icon(Icons.keyboard_arrow_left_rounded),
                    onPressed: () => _controller.previousPage(
                      duration: SpatialMotion.slow.duration,
                      curve: SpatialMotion.slow.curve,
                    ),
                  ),
                  IconButtonM3E(
                    icon: const Icon(Icons.keyboard_arrow_right_rounded),
                    onPressed: () => next(),
                  ),
                ]
              : null,
          backgroundColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            Positioned(
              right: -100,
              top: -30,
              width: 350,
              height: 350,
              child: AnimatedShape(
                text: '',
                excludeShapes: false,
                secondsBeforeShapeChange: 3,
                reactive: false,
                secondsForOneRotation: -50,
                firstColor: context.col.primaryContainer.withAlpha(
                  isDark ? 10 : 50,
                ),
                secondColor: context.col.secondaryContainer.withAlpha(
                  isDark ? 10 : 50,
                ),
              ),
            ),
            Positioned(
              left: -300,
              bottom: -300,
              width: 700,
              height: 700,
              child: AnimatedShape(
                text: '',
                excludeShapes: false,
                secondsBeforeShapeChange: 5,
                reactive: false,
                secondsForOneRotation: 80,
                firstColor: context.col.primaryContainer.withAlpha(
                  isDark ? 30 : 80,
                ),
                secondColor: context.col.tertiaryContainer.withAlpha(
                  isDark ? 30 : 60,
                ),
              ),
            ),
            PageView.builder(
              controller: _controller,
              itemCount: 5,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return RecapCountPage(next: next, recapData: recapData);
                  case 1:
                    return RecapSubjectsPage(next: next, recapData: recapData);
                  case 2:
                    return RecapDaysPage(next: next, recapData: recapData);
                  case 3:
                    return RecapPriorityPage(next: next, recapData: recapData);
                  case 4:
                    return RecapEndPage(recapData: recapData);
                }
                return const Placeholder();
              },
            ),
          ],
        ),
      ),
    );
  }
}
