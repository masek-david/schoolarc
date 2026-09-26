import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:schoolarc/features/timetable/domain/lesson_entity_model.dart';
import 'package:schoolarc/features/timetable/domain/period_model.dart';
import 'package:schoolarc/features/timetable/domain/teacher_model.dart';
import 'package:schoolarc/features/timetable/domain/timetable_entity_model.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_entity_model.dart';
import 'package:schoolarc/models/homeworks/hw_entity_model.dart';
import 'package:schoolarc/models/logs/log_model.dart';
import 'package:schoolarc/models/subjects/subject_entity_model.dart';

part 'hive_adapters.g.dart';

@GenerateAdapters([
  AdapterSpec<HomeworkEntity>(),
  AdapterSpec<ExamEntity>(),
  AdapterSpec<Log>(),
  AdapterSpec<SubjectEntity>(),
  AdapterSpec<Period>(),
  AdapterSpec<TimetableEntity>(),
  AdapterSpec<LessonEntity>(),
  AdapterSpec<Teacher>(),
])
// Annotations must be on some element
// ignore: unused_element
void _() {}
