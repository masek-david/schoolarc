import 'package:flutter/material.dart';

class Period {
  late TimeOfDay startTime;
  late TimeOfDay endTime;
  String name;

  Period({
    required this.startTime,
    required this.endTime,
    this.name = '',
  });

  bool get isActive {
    return startTime.isBefore(TimeOfDay.fromDateTime(DateTime.now())) &&
        TimeOfDay.fromDateTime(DateTime.now()).isBefore(endTime);
  }

  bool get isValid{
    return startTime.isBefore(endTime);
  }

  String toStringFormatted(BuildContext context) {
    return '${startTime.format(context)} - ${endTime.format(context)}';
  }
}
