import 'package:hive_ce/hive.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/logs/log_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/models/timetable/timetable_model.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<Homework>(),
  AdapterSpec<Exam>(),
  AdapterSpec<Log>(),
  AdapterSpec<Subject>(),
  AdapterSpec<LessonTimes>(),
  AdapterSpec<TimeTable>(),
])
// Annotations must be on some element
// ignore: unused_element
void _() {}
