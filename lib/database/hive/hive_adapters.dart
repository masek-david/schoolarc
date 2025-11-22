import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_entity_model.dart';
import 'package:schoolarc/models/homeworks/hw_entity_model.dart';
import 'package:schoolarc/models/logs/log_model.dart';
import 'package:schoolarc/models/subjects/subject_entity_model.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';
import 'package:schoolarc/models/timetable/timetable_entity_model.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<HomeworkEntity>(),
  AdapterSpec<ExamEntity>(),
  AdapterSpec<Log>(),
  AdapterSpec<SubjectEntity>(),
  AdapterSpec<LessonTimes>(),
  AdapterSpec<TimeTableEntity>(),
])
// Annotations must be on some element
// ignore: unused_element
void _() {}
