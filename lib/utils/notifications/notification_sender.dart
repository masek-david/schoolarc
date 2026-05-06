import 'dart:developer';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/l10n/app_localizations.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/task_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/dialogs/show_my_dialog.dart';

const String tomorrowChannel = 'tomorrow_channel';
const String mainChannel = 'main_channel';

class NotificationSender {
  static Future<void> initNotifications() async {
    final loc = getLocalizationWithoutContext();

    await AwesomeNotifications().initialize(
      'resource://drawable/notification_icon',
      [
        NotificationChannel(
          onlyAlertOnce: true,
          channelGroupKey: tomorrowChannel,
          channelKey: tomorrowChannel,
          channelName: loc.upcomingDayNotifications, // localized string
          channelDescription: loc.upcomingDayChannelDescription,
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
        ),
        NotificationChannel(
          onlyAlertOnce: true,
          channelGroupKey: mainChannel,
          channelKey: mainChannel,
          channelName: loc.mainChannel,
          channelDescription: loc.mainChannelDescription,
          defaultColor: Colors.blue,
          ledColor: Colors.blue,
        ),
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: tomorrowChannel,
          channelGroupName: loc.upcomingDayNotifications,
        ),
      ],
      debug: kDebugMode,
    );
  }

  /// Schedules upcoming notification for first possible day.
  /// Will send on settings time and not before weekend if setting set
  /// In total, will schedule 7 notifications, including today.
  ///
  /// If [sendNow], the notification will appear immediately
  ///
  /// [firstUpcoming] will call after all notifications are scheduled with the date of the first notification
  static Future<void> scheduleUpcomingDayNotifications(
    BuildContext context, {
    bool sendNow = false,
    void Function(Date date, TimeOfDay time)? firstUpcoming,
  }) async {
    if (!isCompatiblePlatform()) return;
    final loc = context.loc;
    if (!await areNotificationsAllowed(tomorrowChannel)) return;
    if (!sendNow) {
      AwesomeNotifications().cancelSchedulesByChannelKey(tomorrowChannel);
    }
    await initHive();
    if (!settings.get(Setting.tomorrowNotificationEnabled)) return;

    final TimeOfDay arriveTime = sendNow
        ? TimeOfDay.now()
        : settings.get(Setting.tomorrowNotificationTime);
    final bool beforeWeekend = settings.get(
      Setting.tomorrowNotificationBeforeWeekend,
    );
    final today = Date.today();

    final List<Date> days = [];
    if (sendNow) {
      days.add(Date.today());
    } else {
      int offset = 0;
      if (TimeOfDay.now().isBefore(arriveTime)) {
        offset = 0;
      } else {
        offset = 1;
      }
      while (days.length < 8) {
        final day = today.addDays(offset);
        offset++;
        if (!beforeWeekend && (day.weekday == 5 || day.weekday == 6)) continue;
        days.add(day);
      }
    }

    final subjects = subjectsDb.readDatabase();
    subjects.removeWhere((key, value) => value.isDeleted);
    final hwsInDb = homeworksDb.readDatabase().map(
      (key, value) {
        return MapEntry(key, value.convert(key, subjects[value.subjectId]));
      },
    );
    final examsInDb = examsDb.readDatabase().map(
      (key, value) {
        return MapEntry(key, value.convert(key, subjects[value.subjectId]));
      },
    );
    final exams = examsSortByDate(examsInDb);
    final hws = hwsSortByDate(hwsInDb);

    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      final aboutDay = day.addDays(1);
      final arrive = day.toDateTimeLocal().copyWith(
        hour: arriveTime.hour,
        minute: arriveTime.minute,
      );

      createNotification(
        loc: loc,
        id: i,
        arrive: sendNow ? null : arrive,
        exams: exams[aboutDay] ?? [],
        hws: hws[aboutDay] ?? [],
        missed: hwsGetMissed(hwsInDb, missedBy: aboutDay),
      );
    }

    if (firstUpcoming != null) {
      firstUpcoming(days[0], arriveTime);
    }
  }

  static Future<void> createNotification({
    required AppLocalizations loc,
    required DateTime? arrive,
    required List<Exam> exams,
    required List<Homework> hws,
    required List<Homework> missed,
    required int id,
  }) async {
    final lineBreak = Platform.isIOS ? '\n' : '<br>';

    String body = '';
    // MISSED
    if (missed.isNotEmpty) {
      body += '<b>${loc.missedHomeworkTitle}:</b>$lineBreak';
    }
    for (var hw in missed) {
      body += '${_getTaskText(hw)}$lineBreak';
    }
    if (missed.isNotEmpty) {
      body += lineBreak;
    }
    // EXAMS
    if (exams.isNotEmpty) {
      body += '<b>${loc.exams(2)}:</b>$lineBreak';
    }
    for (var exam in exams) {
      body += '${_getTaskText(exam)}$lineBreak';
    }
    if (exams.isNotEmpty) {
      body += lineBreak;
    }
    // HOMEWORK
    if (hws.isNotEmpty) {
      body += '<b>${loc.homework(2)}:</b>$lineBreak';
    }
    for (var hw in hws) {
      body += '${_getTaskText(hw)}$lineBreak';
    }
    if (hws.isNotEmpty) {
      body += lineBreak;
    }

    String summary = '';

    if (missed.isNotEmpty) {
      summary += '${missed.length} ${loc.missed(missed.length).toLowerCase()}';
    }
    if (hws.isNotEmpty) {
      if (summary != '') {
        summary += ', ';
      }
      summary += '${hws.length} ${loc.homework(hws.length).toLowerCase()}';
    }
    if (exams.isNotEmpty) {
      if (!summary.endsWith(', ') && summary != '') {
        summary += ', ';
      }
      summary += '${exams.length} ${loc.exams(exams.length).toLowerCase()}';
    }

    final schedule = arrive != null
        ? NotificationCalendar.fromDate(
            date: arrive,
            preciseAlarm: true,
            allowWhileIdle: true,
          )
        : null;
    final result = await AwesomeNotifications().createNotification(
      schedule: schedule,
      content: NotificationContent(
        color: Colors.transparent,
        id: id,
        badge: 0,
        channelKey: tomorrowChannel,
        title: loc.tomorrow,
        summary: summary,
        body: body,
        autoDismissible: false,
        category: NotificationCategory.Reminder,
        notificationLayout: NotificationLayout.BigText,
      ),
    );

    if (result) {
      log(
        '\u001b[1;42m\u001b[1;97mTomorrow notification scheduled for: ${arrive?.toLocal().toString()}',
      );
    } else {
      log('error creating notification');
    }
  }

  /// Returns string for task to be put in the notification body
  static String _getTaskText(Task task) {
    final subject = task.subject?.trimmedShortcut;

    final completed = task is Homework && task.isCompleted;

    return '${completed ? '\u2713<i>' : ''}${task.priority.htmlIcon}${subject != null ? ' ${subject.sanitizeHtml()}:' : ''} ${task.text.sanitizeHtml()}</i>';
  }

  static void cancelByChannelKey(String key) {
    AwesomeNotifications().cancelNotificationsByChannelKey(key);
  }

  /// checks all permissions, for the channel if asked
  static Future<bool> areNotificationsAllowed(String? channel) async {
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      return false;
    }
    if (!isCompatiblePlatform()) {
      return false;
    }
    List<NotificationPermission> permission = [];
    try {
      permission = await AwesomeNotifications().checkPermissionList(
        channelKey: channel,
      );
    } on PlatformException {
      return false;
    }
    if (permission.isEmpty) {
      return false;
    }
    return true;
  }

  /// returns true for android or ios
  static bool isCompatiblePlatform() {
    // platform cannot be checked on web
    if (kIsWeb) return false;

    return Platform.isAndroid || Platform.isIOS;
  }

  /// if notifications arent enabled the user is taken to settings/shown request to allow them
  /// then returns true if the user enabled them
  /// on incompatible platforms returns false
  static Future<bool> getPermission(
    BuildContext context,
    String? channel,
  ) async {
    if (!isCompatiblePlatform()) {
      return false;
    }
    if (await areNotificationsAllowed(channel)) {
      return true;
    }
    if (!context.mounted) {
      return false;
    }
    final loc = context.loc;
    return await showMyDialog<bool?>(
          context: context,
          title: loc.notificationPermission,
          actions: [
            DialogActionButton(
              isDestructiveAction: true,
              onPressed: () {
                settings.save(Setting.stopAskingForNotifications, true);
                Navigator.pop(context);
              },
              text: loc.stopAsking,
            ),
            DialogActionButton(
              onPressed: () => Navigator.pop(context),
              text: loc.later,
            ),
            DialogActionButton(
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
              text: loc.grant,
            ),
          ],
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(loc.notificationPermissionBody1),
              const SizedBox(height: 12),
              Text(loc.notificationPermissionBody2),
            ],
          ),
        ) ==
        true;
  }
}
