class UserSettings {
  static final DateTime _scheduledTommorrowNotificationTime = DateTime(0, 0, 0, 13, 10);

  static DateTime getScheduledTommorowNotificationTime(){
    return _scheduledTommorrowNotificationTime;
  }
} 