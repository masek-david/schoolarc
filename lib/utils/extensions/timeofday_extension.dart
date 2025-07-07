import 'package:flutter/material.dart';

extension BetterTimeOfDay on TimeOfDay {
  /// formats the whole time to int, eg. 16:45 would be 1645, must be valid timeofday (hours 0 - 23, minutes 0 - 59)
  int toInt() {
    return 100 * hour + minute;
  }

  // returns datetime with year, month and day being 1, but with the correct time
  DateTime toDateTime() {
    return DateTime.utc(1, 1, 1, hour, minute);
  }

  bool isBefore(TimeOfDay time) {
    return toDateTime().isBefore(time.toDateTime());
  }
}
