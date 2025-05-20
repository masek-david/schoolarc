import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:school_manager/models/exams/exam_entity_model.dart';
import 'package:school_manager/models/homeworks/hw_entity_model.dart';
import 'package:school_manager/models/logs/log_model.dart';
import 'package:school_manager/models/subjects/subject_entity_model.dart';
import 'package:school_manager/models/timetable/lesson_times_model.dart';
import 'package:school_manager/models/timetable/timetable_entity_model.dart';

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
