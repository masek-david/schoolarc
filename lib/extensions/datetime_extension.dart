extension BetterDateTime on DateTime{
  bool isSameDay(DateTime comparedDate){
    return (year == comparedDate.year && month == comparedDate.month && day == comparedDate.day);
  }

  // vrati true pokud je date vcera a drive, false pokud dnes
  bool isBeforeToday(){
    DateTime now = DateTime.now();
    DateTime dateOnlyDate = DateTime(year, month, day);
    DateTime nowOnlyDate = DateTime(now.year, now.month, now.day);

    return dateOnlyDate.isBefore(nowOnlyDate) &&
        !dateOnlyDate.isAtSameMomentAs(nowOnlyDate);
  }

  String minuteStartingWithZero(){
    return minute < 10 ? '0$minute' : minute.toString();
  }

  /// returns all days in this week
  List<DateTime> allDaysInThisWeek(){
    DateTime firstDay = subtract(Duration(days: weekday - 1));
    List<DateTime> list = [];

    for(int i = 0; i < 7; i++){
      list.add(firstDay.add(Duration(days: i)));
    }

    return list;
  }
}