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
}