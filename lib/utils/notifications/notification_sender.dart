import 'dart:developer';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/database/hive/hive_init.dart';
import 'package:school_manager/l10n/my_localization.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/database/settings_database.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/utils/extensions/string_extension.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';

const String tomorrowChannel = 'tomorrow_channel';
const String mainChannel = 'main_channel';

Future<void> initNotifications() async {
  final loc = getLocalization();

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

class NotificationSender {
  // find the correct date for the notification and schedule it
  static void scheduletomorrowNotification({
    bool scheduled = true,
    Function(String text)? showSnackbar,
  }) async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      return;
    }
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
    final loc = getLocalization();

    final dateUtc = arriveDateTime.add(const Duration(days: 1));
    final tomorrowDate = DateTime(dateUtc.year, dateUtc.month, dateUtc.day);

    await initHive();
    final subjects = subjectsDb.getDatabase();
    final hwsInDb = homeworksDb.getDatabase().map(
      (key, value) {
        return MapEntry(key, value.convert(key, subjects[value.subjectId]));
      },
    );
    final examsInDb = examsDb.getDatabase().map(
      (key, value) {
        return MapEntry(key, value.convert(key, subjects[value.subjectId]));
      },
    );
    List<Exam> examsForTomorrow =
        examsSortByDate(examsInDb)[tomorrowDate] ?? [];
    List<Homework> hwsFortomorrow = hwsSortByDate(hwsInDb)[tomorrowDate] ?? [];
    List<Homework> missedHws = hwsGetMissed(hwsInDb);

    final isIOS = Platform.isIOS;
    final lineBreak = isIOS ? '\n' : '<br>';

    // creates text for notification for exam
    for (int i = 0; i < examsForTomorrow.length; i++) {
      Exam exam = examsForTomorrow[i];
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
        '${missedHwTextList != null ? '<b>${loc.missedHomework(2)}:</b>$lineBreak$missedHwTextList$lineBreak' : ''}${examsForTomorrow.isEmpty ? loc.examsFor('true', loc.tomorrow.toLowerCase()).capitalize() : '<b>${loc.exams(2)}:</b>'}$lineBreak$examsTextList$lineBreak${hwsFortomorrow.isEmpty ? loc.homeworksFor('true', loc.tomorrow.toLowerCase()).capitalize() : '<b>${loc.homeworks(2)}:</b>'}$lineBreak$homeworksTextList';

    String summary = '';

    if (missedHws.isNotEmpty) {
      summary +=
          '${missedHws.length} ${loc.missed(missedHws.length).toLowerCase()}';
    }
    if (hwsFortomorrow.isNotEmpty) {
      if (summary != '') {
        summary += ', ';
      }
      summary +=
          '${hwsFortomorrow.length} ${loc.homeworks(hwsFortomorrow.length).toLowerCase()}';
    }
    if (examsForTomorrow.isNotEmpty) {
      if (!summary.endsWith(', ')) {
        summary += ', ';
      }
      summary +=
          '${examsForTomorrow.length} ${loc.exams(examsForTomorrow.length).toLowerCase()}';
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
        title: loc.tomorrow,
        body: notificationText,
        autoDismissible: false,
        category: NotificationCategory.Reminder,
        notificationLayout: NotificationLayout.BigText,
      ),
    );

    log('\u001b[1;42m\u001b[1;30mTomorrow notification scheduled for: ${arriveDateTime.toLocal().toString()}');

    if (showSnackbar != null) {
      showSnackbar(
        loc.nextNotificationInfo(
          arriveDateTime.isSameDay(DateTime.now().toUtc())
              ? loc.today.toLowerCase()
              : loc.tomorrow.toLowerCase(),
          arriveDateTime.formatTime(),
        ),
      );
    }
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
  static bool isCompatiblePlatform() {
    // platform cannot be checked on web
    if (kIsWeb) {
      return false;
    }
    if (Platform.isAndroid || Platform.isIOS) {
      return true;
    }
    return false;
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
    return await showDialogAdaptive<bool?>(
          context: context,
          title: Text(loc.notificationPermission),
          actions: [
            adaptiveDialogButton(
              context: context,
              isDestructiveAction: true,
              onPressed: () {
                settings.save(Setting.stopAskingForNotifications, true);
                Navigator.pop(context);
              },
              child: Text(loc.stopAsking),
            ),
            adaptiveDialogButton(
              context: context,
              onPressed: () => Navigator.pop(context),
              child: Text(loc.later),
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
              child: Text(loc.grant),
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
