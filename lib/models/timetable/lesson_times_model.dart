import 'package:flutter/material.dart';
import 'package:hive_ce/hive.dart';
import 'package:school_manager/utils/extensions/timeofday_extension.dart';

class LessonTimes extends HiveObject {
  late DateTime _startTime;
  late DateTime _endTime;
  String name;

  LessonTimes.fromTimeOfDay({
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    this.name = '',
  }) {
    _startTime = startTime.toDateTime();
    _endTime = endTime.toDateTime();
  }

  LessonTimes({
    required DateTime startTime,
    required DateTime endTime,
    this.name = '',
  }) {
    _startTime = startTime;
    _endTime = endTime;
  }

  TimeOfDay get startTime {
    return TimeOfDay.fromDateTime(_startTime);
  }

  TimeOfDay get endTime {
    return TimeOfDay.fromDateTime(_endTime);
  }

  bool get isActive {
    return startTime.isBefore(TimeOfDay.fromDateTime(DateTime.now())) &&
        TimeOfDay.fromDateTime(DateTime.now()).isBefore(endTime);
  }

  String toStringFormatted(BuildContext context) {
    return '${startTime.format(context)} - ${endTime.format(context)}';
  }
}
