import 'package:flutter/material.dart';
import 'package:schoolarc/models/timetable/lesson_times_model.dart';

class BakaLessonTimes {
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String name;
  final int id;

  BakaLessonTimes({
    required this.startTime,
    required this.endTime,
    required this.name,
    required this.id,
  });

  LessonTimes toLessonTimes() {
    return LessonTimes(
      startTime: startTime,
      endTime: endTime,
      name: name,
    );
  }
}
