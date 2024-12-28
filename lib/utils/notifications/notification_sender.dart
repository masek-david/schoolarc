import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/services/exams/exam_service.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/services/homeworks/hw_service.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/utils/extensions/string_extension.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';

class NotificationSender {
  static const String tommorrowChannel = 'tommorrow_channel';
  static const String mainChannel = 'main_channel';

  static void scheduleTommorrowNotification({
    bool scheduled = true,
    Function(String text)? showSnackbar,
  }) async {
    AwesomeNotifications().cancelSchedulesByChannelKey(tommorrowChannel);

    if (!await areNotificationsAllowed(tommorrowChannel)) {
      return;
    }

    final settings = SettingsDatabase();
    if (!settings.get(Setting.tommorowNotificationEnabled)) {
      AwesomeNotifications().cancelSchedulesByChannelKey(tommorrowChannel);
      return;
    }

    DateTime? tommorowDate;
    // sets correct schedule time and date
    if (scheduled) {
      TimeOfDay notificationTimeOfDay =
          settings.getTimeOfDay(Setting.tommorowNotificationTime);
      DateTime notificationTime = DateTime(
              1, 1, 1, notificationTimeOfDay.hour, notificationTimeOfDay.minute)
          .toUtc();
      DateTime nowUTC = DateTime.now().toUtc();
      DateTime notificationDateTime = DateTime.utc(
        nowUTC.year,
        nowUTC.month,
        nowUTC.day,
        notificationTime.hour,
        notificationTime.minute,
      );

      // if the notification is being set up after it would come today, it will be set to come tommorow
      if (notificationDateTime.isBefore(nowUTC)) {
        notificationDateTime = notificationDateTime.add(const Duration(
          days: 1,
        ));
      }

      tommorowDate = notificationDateTime;
    }

    _scheduleNotificationForDay(
      arriveDateTime: tommorowDate,
      showSnackbar: showSnackbar,
    );
  }

  // schedules notification with info about tommorrow (doesn't need to be provided) for provided date
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

    DateTime tommorowDate = DateTime.utc(
            arriveDateTime.year, arriveDateTime.month, arriveDateTime.day)
        .add(const Duration(days: 1));

    List<ExamDTO> examsForTommorow =
        ExamService().getForDay(tommorowDate);
    List<HomeworkDTO> hwsForTommorow =
        HomeworkService().getForDay(tommorowDate);
    List<HomeworkDTO> missedHws = homeworkService.getMissedHw();

    final isIOS = Platform.isIOS;
    final lineBreak = isIOS ? '\n' : '<br>';

    // creates text for notification for exam
    for (int i = 0; i < examsForTommorow.length; i++) {
      ExamDTO exam = examsForTommorow[i];
      String? subject = exam.subject?.trimmedShortcut.sanitizeHtml();

      String examText =
          '${exam.priority.htmlIcon} ${subject != null ? '$subject:' : ''} ${exam.text.sanitizeHtml()}';

      examsTextList += '$examText$lineBreak';
    }

    // creates text about hw
    hwsForTommorow.sort(
        (a, b) => (a.completion == b.completion ? 0 : (a.completion ? 1 : -1)));
    for (int i = 0; i < hwsForTommorow.length; i++) {
      HomeworkDTO hw = hwsForTommorow[i];
      String? subject = hw.subject?.trimmedShortcut.sanitizeHtml();

      String hwText =
          '${hw.completion ? '\u2713<i>' : ''}${hw.priority.htmlIcon} ${subject != null ? '$subject:' : ''} ${hw.text.sanitizeHtml()}</i>';

      homeworksTextList += '$hwText$lineBreak';
    }

    missedHws.sort((a, b) => a.deadline.compareTo(b.deadline));
    for (int i = 0; i < missedHws.length; i++) {
      HomeworkDTO hw = missedHws[i];
      String? subject = hw.subject?.trimmedShortcut.sanitizeHtml();

      String missedHwText =
          '${hw.completion ? '\u2713<i>' : ''}${hw.priority.htmlIcon} ${subject != null ? '$subject:' : ''} ${hw.text.sanitizeHtml()}</i>';

      missedHwTextList ??= '';
      missedHwTextList += '$missedHwText$lineBreak';
    }

    notificationText =
        '${missedHwTextList != null ? '<b>Missed homeworks:</b>$lineBreak$missedHwTextList$lineBreak' : ''}${examsForTommorow.isEmpty ? 'No exams tommorrow' : '<b>Exams:</b>'}$lineBreak$examsTextList $lineBreak${hwsForTommorow.isEmpty ? 'No homeworks for tommorrow' : '<b>Homeworks:</b>'}$lineBreak$homeworksTextList';

    String summary = '';

    if (missedHws.isNotEmpty) {
      summary += '${missedHws.length} missed';
    }
    if (hwsForTommorow.isNotEmpty) {
      if (summary != '') {
        summary += ', ';
      }
      summary +=
          '${hwsForTommorow.length} homework${hwsForTommorow.length == 1 ? '' : 's'}';
    }
    if (examsForTommorow.isNotEmpty) {
      if (!summary.endsWith(', ')) {
        summary += ', ';
      }
      summary +=
          '${examsForTommorow.length} exam${examsForTommorow.length == 1 ? '' : 's'}';
    }

    await AwesomeNotifications().createNotification(
      schedule: arriveSchedule,
      content: NotificationContent(
        color: Colors.transparent,
        id: 11,
        badge: 0,
        channelKey: tommorrowChannel,
        summary: summary,
        title: 'Tommorrow:',
        body: notificationText,
        autoDismissible: false,
        category: NotificationCategory.Reminder,
        notificationLayout: NotificationLayout.BigText,
      ),
    );

    debugPrintStack(
        label:
            '\u001b[1;42m\u001b[1;30mTommorrow notification scheduled for: ${arriveDateTime.toString()}, in ${arriveDateTime.timeZoneName}');

    if (showSnackbar != null) {
      showSnackbar(
          'Next notification will arrive ${arriveDateTime.isSameDay(DateTime.now().toUtc()) ? 'today' : 'tommorrow'} at around ${arriveDateTime.toLocal().hour}:${arriveDateTime.toLocal().minuteStartingWithZero()}');
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
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
                  child: const Text('Grant permission'),
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
