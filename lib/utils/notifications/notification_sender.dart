import 'dart:developer';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/hive/hive_init.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/utils/extensions/string_extension.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';

const String tomorrowChannel = 'tomorrow_channel';
const String mainChannel = 'main_channel';

Future<void> initNotifications() async {
  await AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    'resource://drawable/res_app_icon',
    [
      NotificationChannel(
        onlyAlertOnce: true,
        channelGroupKey: tomorrowChannel,
        channelKey: tomorrowChannel,
        channelName: 'Upcoming day notifications',
        channelDescription: 'Here you will find upcoming exams and homeworks',
        defaultColor: Colors.transparent,
        ledColor: Colors.blue,
      ),
      NotificationChannel(
        onlyAlertOnce: true,
        channelGroupKey: mainChannel,
        channelKey: mainChannel,
        channelName: 'Main channel',
        channelDescription: 'Main channel for notifications',
        defaultColor: Colors.transparent,
        ledColor: Colors.blue,
      ),
    ],
    // Channel groups are only visual and are not required
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: tomorrowChannel,
        channelGroupName: 'Upcoming day',
      ),
    ],
    debug: kDebugMode,
  );
}

class NotificationSender {
  // find the correct date for the notification and schedule it
  static void scheduletomorrowNotification({
    bool scheduled = true,
    Function(String text)? showSnackbar,
  }) async {
    await initHive();

    if (!await areNotificationsAllowed(tomorrowChannel)) {
      return;
    }

    if (!settings.get(Setting.tomorrowNotificationEnabled)) {
      AwesomeNotifications().cancelSchedulesByChannelKey(tomorrowChannel);
      return;
    }

    DateTime? tomorrowDate;
    // sets correct schedule time and date
    if (scheduled) {
      TimeOfDay notificationTimeOfDay =
          settings.get(Setting.tomorrowNotificationTime);

      DateTime now = DateTime.now();
      DateTime notificationTime = DateTime(now.year, now.month, now.day,
              notificationTimeOfDay.hour, notificationTimeOfDay.minute)
          .toUtc();
      DateTime nowUTC = DateTime.now().toUtc();
      DateTime notificationDateTime = DateTime.utc(
        nowUTC.year,
        nowUTC.month,
        nowUTC.day,
        notificationTime.hour,
        notificationTime.minute,
      );

      // if the notification is being set up after it would come today, it will be set to come tomorrow
      if (notificationDateTime.isBefore(nowUTC)) {
        notificationDateTime = notificationDateTime.add(const Duration(
          days: 1,
        ));
      }

      tomorrowDate = notificationDateTime;
    }

    _scheduleNotificationForDay(
      arriveDateTime: tomorrowDate,
      showSnackbar: showSnackbar,
    );
  }

  // schedules notification with info about tomorrow (doesn't need to be provided) for provided date
  static void _scheduleNotificationForDay({
    Function(String text)? showSnackbar,
    required DateTime? arriveDateTime,
  }) async {
    NotificationCalendar? arriveSchedule;
    if (arriveDateTime != null) {
      arriveSchedule =
          NotificationCalendar.fromDate(date: arriveDateTime.toLocal());
    }
    arriveDateTime ??= DateTime.now().toUtc();

    String notificationText;
    String examsTextList = '';
    String homeworksTextList = '';
    String? missedHwTextList;

    final dateUtc = arriveDateTime.add(Duration(days: 1));
    final tomorrowDate = DateTime(dateUtc.year, dateUtc.month, dateUtc.day);

    await initHive();
    final subjects = subjectsDb.getDatabase();
    final hwsInDb = homeworksDb.getDatabase().map(
      (key, value) {
        return MapEntry(
            key, value.convert(key, subjects[value.subjectId]));
      },
    );
    final examsInDb = examsDb.getDatabase().map(
      (key, value) {
        return MapEntry(
            key, value.convert(key, subjects[value.subjectId]));
      },
    );
    List<Exam> examsFortomorrow =
        examsSortByDate(examsInDb)[tomorrowDate] ?? [];
    List<Homework> hwsFortomorrow =
        hwsSortByDate(hwsInDb)[tomorrowDate] ?? [];
    List<Homework> missedHws = hwsGetMissed(hwsInDb);

    final isIOS = Platform.isIOS;
    final lineBreak = isIOS ? '\n' : '<br>';

    // creates text for notification for exam
    for (int i = 0; i < examsFortomorrow.length; i++) {
      Exam exam = examsFortomorrow[i];
      String? subject = exam.subject?.trimmedShortcut.sanitizeHtml();

      String examText =
          '${exam.priority.htmlIcon} ${subject != null ? '$subject:' : ''} ${exam.text.sanitizeHtml()}';

      examsTextList += '$examText$lineBreak';
    }

    // creates text about hw
    hwsFortomorrow.sort((a, b) =>
        (a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1)));
    for (int i = 0; i < hwsFortomorrow.length; i++) {
      Homework hw = hwsFortomorrow[i];
      String? subject = hw.subject?.trimmedShortcut.sanitizeHtml();

      String hwText =
          '${hw.isCompleted ? '\u2713<i>' : ''}${hw.priority.htmlIcon} ${subject != null ? '$subject:' : ''} ${hw.text.sanitizeHtml()}</i>';

      homeworksTextList += '$hwText$lineBreak';
    }

    missedHws.sort((a, b) => a.deadline.compareTo(b.deadline));
    for (int i = 0; i < missedHws.length; i++) {
      Homework hw = missedHws[i];
      String? subject = hw.subject?.trimmedShortcut.sanitizeHtml();

      String missedHwText =
          '${hw.isCompleted ? '\u2713<i>' : ''}${hw.priority.htmlIcon} ${subject != null ? '$subject:' : ''} ${hw.text.sanitizeHtml()}</i>';

      missedHwTextList ??= '';
      missedHwTextList += '$missedHwText$lineBreak';
    }

    notificationText =
        '${missedHwTextList != null ? '<b>Missed homeworks:</b>$lineBreak$missedHwTextList$lineBreak' : ''}${examsFortomorrow.isEmpty ? 'No exams tomorrow' : '<b>Exams:</b>'}$lineBreak$examsTextList $lineBreak${hwsFortomorrow.isEmpty ? 'No homeworks for tomorrow' : '<b>Homeworks:</b>'}$lineBreak$homeworksTextList';

    String summary = '';

    if (missedHws.isNotEmpty) {
      summary += '${missedHws.length} missed';
    }
    if (hwsFortomorrow.isNotEmpty) {
      if (summary != '') {
        summary += ', ';
      }
      summary +=
          '${hwsFortomorrow.length} homework${hwsFortomorrow.length == 1 ? '' : 's'}';
    }
    if (examsFortomorrow.isNotEmpty) {
      if (!summary.endsWith(', ')) {
        summary += ', ';
      }
      summary +=
          '${examsFortomorrow.length} exam${examsFortomorrow.length == 1 ? '' : 's'}';
    }

    AwesomeNotifications().cancelSchedulesByChannelKey(tomorrowChannel);
    await AwesomeNotifications().createNotification(
      schedule: arriveSchedule,
      content: NotificationContent(
        color: Colors.transparent,
        id: 11,
        badge: 0,
        channelKey: tomorrowChannel,
        summary: summary,
        title: 'Tomorrow:',
        body: notificationText,
        autoDismissible: false,
        category: NotificationCategory.Reminder,
        notificationLayout: NotificationLayout.BigText,
      ),
    );

    log('\u001b[1;42m\u001b[1;30mtomorrow notification scheduled for: ${arriveDateTime.toLocal().toString()}');

    if (showSnackbar != null) {
      showSnackbar(
          'Next notification will arrive ${arriveDateTime.isSameDay(DateTime.now().toUtc()) ? 'today' : 'tomorrow'} at around ${arriveDateTime.toLocal().hour}:${arriveDateTime.toLocal().minuteStartingWithZero()}');
    }
  }

  /// checks all permissions, for the channel if asked
  static Future<bool> areNotificationsAllowed(String? channel) async {
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      return false;
    }
    if (!_isCompatiblePlatform()) {
      return false;
    }
    List<NotificationPermission> permission = [];
    try {
      permission =
          await AwesomeNotifications().checkPermissionList(channelKey: channel);
    } on PlatformException {
      return false;
    }
    if (permission.isEmpty) {
      return false;
    }
    return true;
  }

  /// returns true for android or ios
  static bool _isCompatiblePlatform() {
    // platform cannot be checked on web
    if(kIsWeb){
      return false;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return true;
    }
    return false;
  }

  /// returns true if notifications are enabled, if they arent the user is taken to setting/shown request to allow them
  static Future<bool> getPermission(
    BuildContext context,
    String? channel,
  ) async {
    if(!_isCompatiblePlatform()){
      return false;
    }
    if (await areNotificationsAllowed(channel)) {
      return true;
    }
    if (!context.mounted) {
      return false;
    }
    return await showDialogAdaptive<bool?>(
              context: context,
              title: const Text(
                'Notification Permission',
              ),
              actions: [
                adaptiveDialogButton(
                  context: context,
                  isDestructiveAction: true,
                  onPressed: () {
                    settings.save(Setting.stopAskingForNotifications, true);
                    Navigator.pop(context);
                  },
                  child: const Text('Stop asking'),
                ),
                adaptiveDialogButton(
                  context: context,
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Later'),
                ),
                adaptiveDialogButton(
                  context: context,
                  onPressed: () async {
                    await AwesomeNotifications()
                        .requestPermissionToSendNotifications(
                      channelKey: channel,
                    );
                    bool allowed = await areNotificationsAllowed(channel);
                    if (context.mounted) {
                      Navigator.pop(context, allowed);
                    }
                  },
                  isDefaultAction: true,
                  child: const Text('Grant'),
                ),
              ],
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'If you want this app to send you notifications, you need to grant it permission.',
                  ),
                  SizedBox(height: 12),
                  Text(
                    'The Grant permission button will take you to app settings from where you can enable all notifications.',
                  ),
                ],
              ),
            ) ==
            true
        ? true
        : false;
  }
}
