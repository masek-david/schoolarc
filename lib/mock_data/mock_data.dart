import 'package:flutter/material.dart';
import 'package:schoolarc/models/bakalari/teacher_model.dart';
import 'package:schoolarc/models/bakalari/timetable_change_model.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_entity_model.dart';
import 'package:schoolarc/models/homeworks/hw_entity_model.dart';
import 'package:schoolarc/models/meal_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/models/timetable/timetable_entry_model.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';

class MockData {
  static const useMock = false;

  // Note: this should be a monday
  static const firstDate = Date(2026, 1, 26);
  // Note: this should be a monday as well, because of the timetable
  // Easiest way to change datetime.now is to change device date (ideally to time of 8:15)
  static const _today = Date(2026, 2, 2);

  static final subjects = {
    '0': Subject(
      id: '0',
      bakaId: '0',
      name: 'Mathematics',
      shortcut: 'Ma',
      order: 0,
      isDeleted: false,
      timestamp: DateTime.now(),
    ),
    '1': Subject(
      id: '1',
      bakaId: '1',
      name: 'Physics',
      shortcut: 'Ph',
      order: 1,
      isDeleted: false,
      timestamp: DateTime.now(),
    ),
    '2': Subject(
      id: '2',
      bakaId: '2',
      name: 'Chemistry',
      shortcut: 'Ch',
      order: 2,
      isDeleted: false,
      timestamp: DateTime.now(),
    ),
    '3': Subject(
      id: '3',
      bakaId: '3',
      name: 'Biology',
      shortcut: 'Bi',
      order: 3,
      isDeleted: false,
      timestamp: DateTime.now(),
    ),
    '4': Subject(
      id: '4',
      bakaId: '4',
      name: 'English',
      shortcut: 'En',
      order: 4,
      isDeleted: false,
      timestamp: DateTime.now(),
    ),
    '5': Subject(
      id: '5',
      bakaId: '5',
      name: 'History',
      shortcut: 'Hi',
      order: 5,
      isDeleted: false,
      timestamp: DateTime.now(),
    ),
    '6': Subject(
      id: '6',
      bakaId: '6',
      name: 'Geography',
      shortcut: 'Ge',
      order: 6,
      isDeleted: false,
      timestamp: DateTime.now(),
    ),
    '7': Subject(
      id: '7',
      bakaId: '7',
      name: 'Computer Science',
      shortcut: 'CS',
      order: 7,
      isDeleted: false,
      timestamp: DateTime.now(),
    ),
    '8': Subject(
      id: '8',
      bakaId: '8',
      name: 'Art',
      shortcut: 'Art',
      order: 8,
      isDeleted: false,
      timestamp: DateTime.now(),
    ),
    '9': Subject(
      id: '9',
      bakaId: '9',
      name: 'Physical Education',
      shortcut: 'PE',
      order: 9,
      isDeleted: false,
      timestamp: DateTime.now(),
    ),
  };

  static HomeworkEntity _createHw(
    String text,
    bool hasDescription,
    String subjectId,
    Date date,
    bool isMissed,
    int priority,
    double order,
  ) {
    return HomeworkEntity(
      text: text,
      subjectId: subjectId,
      date: date,
      priority: priority,
      order: order,
      isCompleted: isMissed ? false : date.isBefore(_today),
      isDeleted: false,
      timestamp: DateTime.now(),
    );
  }

  static ExamEntity _createExam(
    String text,
    bool hasDescription,
    String subjectId,
    Date date,
    int priority,
    double order,
  ) {
    return ExamEntity(
      text: text,
      subjectId: subjectId,
      date: date,
      priority: priority,
      order: order,
      isDeleted: false,
      timestamp: DateTime.now(),
    );
  }

  static final hws = {
    '4': _createHw(
      'Essay outline',
      false,
      '4',
      firstDate.addDays(0),
      true,
      2,
      4,
    ),
    '0': _createHw(
      'Linear equations worksheet',
      false,
      '0',
      firstDate.addDays(1),
      false,
      1,
      0,
    ),
    '1': _createHw(
      'Forces problem set',
      false,
      '1',
      firstDate.addDays(7),
      false,
      2,
      1,
    ),
    '2': _createHw(
      'Lab safety questions',
      false,
      '2',
      firstDate.addDays(3),
      false,
      0,
      2,
    ),
    '3': _createHw(
      'Plant cell diagram',
      true,
      '3',
      firstDate.addDays(4),
      false,
      1,
      3,
    ),
    '5': _createHw(
      'Industrial revolution notes',
      false,
      '5',
      firstDate.addDays(2),
      false,
      1,
      5,
    ),
    '6': _createHw(
      'River systems worksheet',
      false,
      '6',
      firstDate.addDays(8),
      false,
      0,
      6,
    ),
    '7': _createHw(
      'OOP concepts summary',
      true,
      '7',
      firstDate.addDays(8),
      false,
      3,
      7,
    ),
    '8': _createHw(
      'Shading techniques practice',
      false,
      '8',
      firstDate.addDays(9),
      false,
      0,
      8,
    ),
    '9': _createHw(
      'Warm-up routine log',
      false,
      '9',
      firstDate.addDays(10),
      false,
      0,
      9,
    ),

    '10': _createHw(
      'Quadratic functions',
      false,
      '0',
      firstDate.addDays(11),
      false,
      2,
      10,
    ),
    '11': _createHw(
      'Energy conservation tasks',
      false,
      '1',
      firstDate.addDays(4),
      false,
      3,
      11,
    ),
    '12': _createHw(
      'Chemical reactions table',
      true,
      '2',
      firstDate.addDays(14),
      false,
      1,
      12,
    ),
    '13': _createHw(
      'Genetics worksheet',
      false,
      '3',
      firstDate.addDays(14),
      false,
      2,
      13,
    ),
    '14': _createHw(
      'Reading comprehension',
      false,
      '4',
      firstDate.addDays(15),
      false,
      1,
      14,
    ),
    '15': _createHw(
      'Cold War questions',
      false,
      '5',
      firstDate.addDays(16),
      false,
      2,
      15,
    ),
    '16': _createHw(
      'Population pyramid task',
      false,
      '6',
      firstDate.addDays(18),
      false,
      1,
      16,
    ),
    '17': _createHw(
      'State management demo',
      true,
      '7',
      firstDate.addDays(22),
      false,
      3,
      17,
    ),
    '18': _createHw(
      'Color mixing chart',
      false,
      '8',
      firstDate.addDays(22),
      false,
      0,
      18,
    ),
    '19': _createHw(
      'Stretching routine checklist',
      false,
      '9',
      firstDate.addDays(25),
      false,
      0,
      19,
    ),
  };

  static final exams = {
    '0': _createExam('Algebra test', false, '0', firstDate.addDays(2), 3, 0),
    '1': _createExam(
      'Physics mechanics exam',
      true,
      '1',
      firstDate.addDays(4),
      3,
      1,
    ),
    '2': _createExam(
      'Chemistry unit test',
      false,
      '2',
      firstDate.addDays(7),
      2,
      2,
    ),
    '3': _createExam('Biology quiz', false, '3', firstDate.addDays(9), 1, 3),
    '4': _createExam(
      'English literature test',
      false,
      '4',
      firstDate.addDays(9),
      2,
      4,
    ),
    '5': _createExam(
      'Modern history exam',
      true,
      '5',
      firstDate.addDays(11),
      3,
      5,
    ),
    '6': _createExam(
      'Geography regions test',
      false,
      '6',
      firstDate.addDays(15),
      1,
      6,
    ),
    '7': _createExam(
      'Programming fundamentals',
      false,
      '7',
      firstDate.addDays(18),
      3,
      7,
    ),
    '8': _createExam(
      'Art practical assessment',
      false,
      '8',
      firstDate.addDays(23),
      1,
      8,
    ),
    '9': _createExam(
      'Physical fitness evaluation',
      false,
      '9',
      firstDate.addDays(25),
      0,
      9,
    ),
  };

  static final actualTimetable = Timetable(
    dates: List.generate(
      5,
      (index) => _today.addDays(index),
    ),
    lessonTimes: [
      LessonTimes(
        name: '1',
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 8, minute: 45),
      ),
      LessonTimes(
        name: '2',
        startTime: const TimeOfDay(hour: 8, minute: 50),
        endTime: const TimeOfDay(hour: 9, minute: 35),
      ),
      LessonTimes(
        name: '3',
        startTime: const TimeOfDay(hour: 9, minute: 50),
        endTime: const TimeOfDay(hour: 10, minute: 35),
      ),
      LessonTimes(
        name: '4',
        startTime: const TimeOfDay(hour: 10, minute: 50),
        endTime: const TimeOfDay(hour: 11, minute: 35),
      ),
      LessonTimes(
        name: '5',
        startTime: const TimeOfDay(hour: 11, minute: 40),
        endTime: const TimeOfDay(hour: 12, minute: 25),
      ),
      LessonTimes(
        name: '6',
        startTime: const TimeOfDay(hour: 12, minute: 30),
        endTime: const TimeOfDay(hour: 13, minute: 15),
      ),
    ],
    table: [
      // Monday
      [
        TimetableEntry(
          subject: subjects['0'],
          room: '101',
          teacher: Teacher(name: 'Mr. Smith', shortcut: 'S'),
        ),
        TimetableEntry(
          subject: subjects['1'],
          room: '102',
          change: BakaChange(type: .substitution, description: ''),
          teacher: Teacher(name: 'Ms. Jones', shortcut: 'J'),
        ),
        TimetableEntry(
          subject: subjects['2'],
          room: '103',
          teacher: Teacher(name: 'Dr. Brown', shortcut: 'B'),
        ),
        TimetableEntry(
          subject: null,
          room: null,
          change: BakaChange(type: .removed, description: 'Cancelled'),
          teacher: null,
        ),
        TimetableEntry(
          subject: subjects['4'],
          room: '105',
          teacher: Teacher(name: 'Mr. Green', shortcut: 'G'),
        ),
        TimetableEntry.empty(),
      ],
      // Tuesday
      [
        TimetableEntry(
          subject: subjects['5'],
          room: '201',
          teacher: Teacher(name: 'Ms. Black', shortcut: 'Bl'),
        ),
        TimetableEntry(
          subject: subjects['6'],
          room: '202',
          teacher: Teacher(name: 'Mr. Grey', shortcut: 'Gr'),
        ),
        TimetableEntry(
          subject: subjects['7'],
          room: '203',
          teacher: Teacher(name: 'Mrs. Violet', shortcut: 'V'),
        ),
        TimetableEntry(
          subject: subjects['8'],
          room: '204',
          teacher: Teacher(name: 'Ms. Indigo', shortcut: 'I'),
        ),
        TimetableEntry(
          subject: subjects['9'],
          room: 'Gym',
          change: BakaChange(type: .added, description: 'Substitute teacher'),
          teacher: Teacher(name: 'Mr. Cyan', shortcut: 'C'),
        ),
        TimetableEntry(
          subject: subjects['9'],
          room: 'Gym',
          change: BakaChange(type: .added, description: 'Substitute teacher'),
          teacher: Teacher(name: 'Mr. Cyan', shortcut: 'C'),
        ),
      ],
      // Wednesday
      [
        TimetableEntry(
          subject: subjects['0'],
          room: '101',
          teacher: Teacher(name: 'Mr. Smith', shortcut: 'S'),
        ),
        TimetableEntry(
          subject: subjects['2'],
          room: '103',
          teacher: Teacher(name: 'Dr. Brown', shortcut: 'B'),
        ),
        TimetableEntry(
          subject: subjects['4'],
          room: '105',
          teacher: Teacher(name: 'Mr. Green', shortcut: 'G'),
        ),
        TimetableEntry(
          subject: subjects['6'],
          room: '202',
          change: BakaChange(type: .added, description: ''),
          teacher: Teacher(name: 'Mr. Grey', shortcut: 'Gr'),
        ),
        TimetableEntry(
          subject: subjects['8'],
          room: '204',
          teacher: Teacher(name: 'Ms. Indigo', shortcut: 'I'),
        ),
        TimetableEntry.empty(),
      ],
      // Thursday
      [
        TimetableEntry(
          subject: subjects['1'],
          room: '102',
          teacher: Teacher(name: 'Ms. Jones', shortcut: 'J'),
        ),
        TimetableEntry(
          subject: subjects['3'],
          room: '104',
          change: BakaChange(type: .added, description: 'Group work'),
          teacher: Teacher(name: 'Mrs. White', shortcut: 'W'),
        ),
        TimetableEntry(
          subject: subjects['5'],
          room: '201',
          teacher: Teacher(name: 'Ms. Black', shortcut: 'Bl'),
        ),
        TimetableEntry(
          subject: subjects['7'],
          room: '203',
          teacher: Teacher(name: 'Mrs. Violet', shortcut: 'V'),
        ),
        TimetableEntry.empty(),
        TimetableEntry.empty(),
      ],
      // Friday
      [
        TimetableEntry(
          subject: subjects['0'],
          room: '101',
          teacher: Teacher(name: 'Mr. Smith', shortcut: 'S'),
        ),
        TimetableEntry(
          subject: subjects['2'],
          room: '103',
          teacher: Teacher(name: 'Dr. Brown', shortcut: 'B'),
        ),
        TimetableEntry(
          subject: subjects['4'],
          room: '105',
          teacher: Teacher(name: 'Mr. Green', shortcut: 'G'),
        ),
        TimetableEntry(
          subject: subjects['6'],
          room: '202',
          teacher: Teacher(name: 'Mr. Grey', shortcut: 'Gr'),
        ),
        TimetableEntry(
          subject: subjects['8'],
          room: '204',
          change: BakaChange(type: .removed, description: 'Teacher absent'),
          teacher: Teacher(name: 'Ms. Indigo', shortcut: 'I'),
        ),
        TimetableEntry.empty(),
      ],
      // saturday
      List.filled(6, TimetableEntry.empty()),
      // sunday
      List.filled(6, TimetableEntry.empty()),
    ],
  );

  static final timetable = Timetable(
    dates: List.generate(
      5,
      (index) => _today.addDays(index),
    ),
    lessonTimes: [
      LessonTimes(
        name: '1',
        startTime: const TimeOfDay(hour: 8, minute: 0),
        endTime: const TimeOfDay(hour: 8, minute: 45),
      ),
      LessonTimes(
        name: '2',
        startTime: const TimeOfDay(hour: 8, minute: 50),
        endTime: const TimeOfDay(hour: 9, minute: 35),
      ),
      LessonTimes(
        name: '3',
        startTime: const TimeOfDay(hour: 9, minute: 50),
        endTime: const TimeOfDay(hour: 10, minute: 35),
      ),
      LessonTimes(
        name: '4',
        startTime: const TimeOfDay(hour: 10, minute: 50),
        endTime: const TimeOfDay(hour: 11, minute: 35),
      ),
      LessonTimes(
        name: '5',
        startTime: const TimeOfDay(hour: 11, minute: 40),
        endTime: const TimeOfDay(hour: 12, minute: 25),
      ),
      LessonTimes(
        name: '6',
        startTime: const TimeOfDay(hour: 12, minute: 30),
        endTime: const TimeOfDay(hour: 13, minute: 15),
      ),
    ],
    table: [
      // Monday
      [
        TimetableEntry(
          subject: subjects['0'],
          room: '101',
          teacher: Teacher(name: 'Mr. Smith', shortcut: 'S'),
        ),
        TimetableEntry(
          subject: subjects['1'],
          room: '102',
          teacher: Teacher(name: 'Ms. Jones', shortcut: 'J'),
        ),
        TimetableEntry(
          subject: subjects['2'],
          room: '103',
          teacher: Teacher(name: 'Dr. Brown', shortcut: 'B'),
        ),
        TimetableEntry(
          subject: null,
          room: null,
          teacher: null,
        ),
        TimetableEntry(
          subject: subjects['4'],
          room: '105',
          teacher: Teacher(name: 'Mr. Green', shortcut: 'G'),
        ),
        TimetableEntry.empty(),
      ],
      // Tuesday
      [
        TimetableEntry(
          subject: subjects['5'],
          room: '201',
          teacher: Teacher(name: 'Ms. Black', shortcut: 'Bl'),
        ),
        TimetableEntry(
          subject: subjects['6'],
          room: '202',
          teacher: Teacher(name: 'Mr. Grey', shortcut: 'Gr'),
        ),
        TimetableEntry(
          subject: subjects['7'],
          room: '203',
          teacher: Teacher(name: 'Mrs. Violet', shortcut: 'V'),
        ),
        TimetableEntry(
          subject: subjects['8'],
          room: '204',
          teacher: Teacher(name: 'Ms. Indigo', shortcut: 'I'),
        ),
        TimetableEntry(
          subject: subjects['9'],
          room: 'Gym',
          teacher: Teacher(name: 'Mr. Cyan', shortcut: 'C'),
        ),
        TimetableEntry(
          subject: subjects['9'],
          room: 'Gym',
          teacher: Teacher(name: 'Mr. Cyan', shortcut: 'C'),
        ),
      ],
      // Wednesday
      [
        TimetableEntry(
          subject: subjects['0'],
          room: '101',
          teacher: Teacher(name: 'Mr. Smith', shortcut: 'S'),
        ),
        TimetableEntry(
          subject: subjects['2'],
          room: '103',
          teacher: Teacher(name: 'Dr. Brown', shortcut: 'B'),
        ),
        TimetableEntry(
          subject: subjects['4'],
          room: '105',
          teacher: Teacher(name: 'Mr. Green', shortcut: 'G'),
        ),
        TimetableEntry(
          subject: subjects['6'],
          room: '202',
          teacher: Teacher(name: 'Mr. Grey', shortcut: 'Gr'),
        ),
        TimetableEntry(
          subject: subjects['8'],
          room: '204',
          teacher: Teacher(name: 'Ms. Indigo', shortcut: 'I'),
        ),
        TimetableEntry.empty(),
      ],
      // Thursday
      [
        TimetableEntry(
          subject: subjects['1'],
          room: '102',
          teacher: Teacher(name: 'Ms. Jones', shortcut: 'J'),
        ),
        TimetableEntry(
          subject: subjects['3'],
          room: '104',
          teacher: Teacher(name: 'Mrs. White', shortcut: 'W'),
        ),
        TimetableEntry(
          subject: subjects['5'],
          room: '201',
          teacher: Teacher(name: 'Ms. Black', shortcut: 'Bl'),
        ),
        TimetableEntry(
          subject: subjects['7'],
          room: '203',
          teacher: Teacher(name: 'Mrs. Violet', shortcut: 'V'),
        ),
        TimetableEntry.empty(),
        TimetableEntry.empty(),
      ],
      // Friday
      [
        TimetableEntry(
          subject: subjects['0'],
          room: '101',
          teacher: Teacher(name: 'Mr. Smith', shortcut: 'S'),
        ),
        TimetableEntry(
          subject: subjects['2'],
          room: '103',
          teacher: Teacher(name: 'Dr. Brown', shortcut: 'B'),
        ),
        TimetableEntry(
          subject: subjects['4'],
          room: '105',
          teacher: Teacher(name: 'Mr. Green', shortcut: 'G'),
        ),
        TimetableEntry(
          subject: subjects['6'],
          room: '202',
          teacher: Teacher(name: 'Mr. Grey', shortcut: 'Gr'),
        ),
        TimetableEntry(
          subject: subjects['8'],
          room: '204',
          teacher: Teacher(name: 'Ms. Indigo', shortcut: 'I'),
        ),
        TimetableEntry.empty(),
      ],
      // saturday
      List.filled(6, TimetableEntry.empty()),
      // sunday
      List.filled(6, TimetableEntry.empty()),
    ],
  );

  static final meals = {
    _today: [
      Meal(type: 'Soup', name: 'Tomato soup with basil'),
      Meal(
        type: 'Meal 1',
        name: 'Grilled chicken with rice and steamed vegetables',
        selected: true,
      ),
      Meal(type: 'Meal 2', name: 'Vegetable stir-fry with tofu'),
    ],
    _today.addDays(1): [
      Meal(type: 'Soup', name: 'Chicken noodle soup'),
      Meal(type: 'Meal 1', name: 'Beef goulash with dumplings', selected: true),
      Meal(type: 'Meal 2', name: 'Caesar salad with grilled halloumi'),
    ],
    _today.addDays(2): [
      Meal(type: 'Soup', name: 'Broccoli cream soup'),
      Meal(type: 'Meal 1', name: 'Spaghetti Bolognese', selected: true),
      Meal(type: 'Meal 2', name: 'Spinach risotto with parmesan'),
    ],
    _today.addDays(3): [
      Meal(type: 'Soup', name: 'Lentil soup'),
      Meal(
        type: 'Meal 1',
        name: 'Roast pork with mashed potatoes and cabbage',
        selected: true,
      ),
    ],
    _today.addDays(4): [
      Meal(type: 'Soup', name: 'Garlic potato soup'),
      Meal(type: 'Meal 1', name: 'Turkey schnitzel with fries'),
      Meal(type: 'Meal 2', name: 'Greek salad with pita bread', selected: true),
    ],
  };
}
