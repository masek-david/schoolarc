import 'package:flutter/material.dart';

extension BetterTimeOfDay on TimeOfDay{
  String minuteStartingWithZero(){
    return minute < 10 ? '0$minute' : minute.toString();
  }

  // returns datetime with year, month and day being 1, but with the correct time
  DateTime toDateTime(){
    return DateTime.utc(1, 1, 1, hour, minute);
  }
}