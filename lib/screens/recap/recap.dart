import 'dart:convert';

import 'package:cbor/cbor.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/utils/globals.dart';

class RecapData {
  RecapData({
    required this.name,
    required this.year,
    required this.colorIndex,
    required this.homeworksCount,
    required this.examsCount,
    required this.days,
    required this.priorities,
    required this.subjects,
  });

  final String name;
  final String year;
  final int? colorIndex;
  final int homeworksCount;
  final int examsCount;
  final List<int> days;
  final List<int> priorities;
  final List<SubjectWithUsedTimes> subjects;

  bool get needsMoreData {
    if (subjects.length < 3) {
      return true;
    }
    if (priorities.length < 4) {
      return true;
    }
    if (days.length < 7) {
      return true;
    }
    return false;
  }

  /// used for generating whole new recapdata, from homeworks and exams
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
      colorIndex: null,
      name: name,
      year: year,
      homeworksCount: hws.length,
      examsCount: exams.length,
      days: days,
      priorities: priorities,
      subjects: subjects,
    );
  }

  ///  start with 'sti$version', then encodes with cbor the name, year, index of the color from [presetColors], hwcount, examcount, subjects - pair of shortcut and count, 7 days, and 4 priorities
  Uri encode() {
    final subjectsEncoded = subjects
        .take(3)
        .map(
          (e) => [
            e.subject.shortcut,
            e.usedTimes,
          ],
        )
        .toList();

    final data = CborValue([
      name,
      colorIndex,
      homeworksCount,
      examsCount,
      subjectsEncoded,
      days,
      priorities,
    ]);

    final List<int> bytes = cborEncode(data);
    final base64 = base64UrlEncode(bytes);

    return Uri(
      scheme: 'schoolarc',
      host: '',
      queryParameters: {
        stiVersion[year] ?? 'sti': base64,
      },
    );
  }

  static const years = {'sti0': '2025-26'};
  static const stiVersion = {'sti0': '2025-26'};

  factory RecapData.decode(String input) {
    // "sti0=h2VEYXZpZAQYqhhsg4JkxIxqbBgsgmJNYRglgmJGeRgahxguGCsYKxg3GEoHCoQYTRgzGGAYNg=="
    final stickerVersion = input.substring(0, input.indexOf('='));
    final year = years[stickerVersion] ?? '';
    final inputCleaned = input.substring(input.indexOf('=') + 1);
    final bytes = base64Url.decode(inputCleaned);
    final list = (cbor.decode(bytes).toObject() as List);

    final name = list[0];
    final colorIndex = list[1];
    final homeworksCount = list[2];
    final examsCount = list[3];

    final subjects = <SubjectWithUsedTimes>[];
    for (final entry in list[4]) {
      subjects.add(
        SubjectWithUsedTimes(
          subject: Subject(
            name: '',
            shortcut: entry[0],
            id: '',
            bakaId: '',
            timestamp: DateTime.now(),
            isDeleted: false,
            order: 0,
          ),
          usedTimes: entry[1],
        ),
      );
    }

    final days = (list[5] as List).map<int>((e) => e).toList();
    final priorities = (list[6] as List).map<int>((e) => e).toList();

    return RecapData(
      year: year,
      name: name,
      colorIndex: colorIndex,
      homeworksCount: homeworksCount,
      examsCount: examsCount,
      subjects: subjects,
      days: days,
      priorities: priorities,
    );
  }

  RecapData copyWith({
    String? name,
    String? year,
    int? colorIndex,
    int? homeworksCount,
    int? examsCount,
    List<int>? days,
    List<int>? priorities,
    List<SubjectWithUsedTimes>? subjects,
  }) {
    return RecapData(
      name: name ?? this.name,
      year: year ?? this.year,
      colorIndex: colorIndex ?? this.colorIndex,
      homeworksCount: homeworksCount ?? this.homeworksCount,
      examsCount: examsCount ?? this.examsCount,
      days: days ?? this.days,
      priorities: priorities ?? this.priorities,
      subjects: subjects ?? this.subjects,
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

// returns true if it is last three weeks of school
bool isRecapDate() {
  final now = DateTime.now();

  return now.isAfter(DateTime(now.year, 6, 15)) &&
      now.isBefore(DateTime(now.year, 7, 8));
}
