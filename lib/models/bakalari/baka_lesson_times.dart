import 'package:flutter/material.dart';
import 'package:schoolarc/features/timetable/domain/period_model.dart';

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

  Period toPeriod() {
    return Period(
      startTime: startTime,
      endTime: endTime,
      name: name,
    );
  }
}
