import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';
import 'package:school_manager/data/exams_data/exam_service.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/data/homeworks_data/hw_service.dart';
import 'package:school_manager/data/priority_model.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/extensions/datetime_extension.dart';
import 'package:school_manager/extensions/string_extension.dart';

class NotificationSender {
  /// if not scheduled, it will arrive now and never automatically expire
  static void sendQuickAdd(bool scheduled) async {
    if (!isCompatiblePlatform()) {
      return;
    }
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      AwesomeNotifications().cancelSchedulesByChannelKey('persistent_group');
      return;
    }

    NotificationCalendar? schedule;
    Duration? timeoutAfter;

    if (scheduled) {
      SettingsDatabase settings = SettingsDatabase();

      if (!settings.quickAddEnabled()) {
        return;
      } else {
        AwesomeNotifications().cancelSchedulesByChannelKey('persistent_group');

        DateTime now = DateTime.now();
        TimeOfDay arriveTime = settings.quickAddArriveTime();
        DateTime arriveDate = DateTime(
          now.year,
          now.month,
          now.day,
          arriveTime.hour,
          arriveTime.minute,
        );
        TimeOfDay dismissTime = settings.quickAddDissappearTime();
        DateTime dismissDate = DateTime(
          arriveDate.year,
          arriveDate.month,
          arriveDate.day,
          dismissTime.hour,
          dismissTime.minute,
        );

        // if the notification is being set up after it would come today, it will be set to come tommorow
        if (arriveDate.isBefore(now)) {
          arriveDate = arriveDate.add(const Duration(
            days: 1,
          ));
        }

        if (settings.quickAddOnWeekends() && arriveDate.weekday == 6 ||
            arriveDate.weekday == 7) {
          arriveDate.add(Duration(days: 8 - arriveDate.weekday));
        }

        timeoutAfter = dismissDate.difference(arriveDate);

        schedule = NotificationCalendar(
          year: arriveDate.year,
          month: arriveDate.month,
          day: arriveDate.day,
          hour: arriveDate.hour,
          minute: arriveDate.minute,
        );
      }
    }

    AwesomeNotifications().createNotification(
      schedule: schedule,
      content: NotificationContent(
        id: 10,
        timeoutAfter: timeoutAfter,
        channelKey: 'persistent_channel',
        title: 'Quick add',
        body: 'You can add homework or exam right from this notification',
        autoDismissible: false,
        locked: true,
        category: NotificationCategory.Status,
        actionType: ActionType.DisabledAction,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'homework',
          label: 'Homework',
          requireInputText: true,
        ),
        NotificationActionButton(
          key: 'exam',
          label: 'Exam',
          requireInputText: true,
        ),
        NotificationActionButton(
          key: 'close',
          label: 'Close',
          actionType: ActionType.DisabledAction,
        ),
      ],
    );
  }

  // will set new notification about tommorrow, if not scheduled, it will arrive now and never automatically expire
  static void scheduleTommorrowNotification({
    bool scheduled = true,
    Function(String text)? showSnackbar,
  }) {
    if (!isCompatiblePlatform()) {
      return;
    }

    SettingsDatabase settings = SettingsDatabase();

    if (!settings.tommorrowNotificationEnabled()) {
      AwesomeNotifications()
          .cancelSchedulesByChannelKey('tommorrow_channel_group');
      return;
    }

    DateTime? schedule;

    // sets correct schedule time and date
    if (scheduled) {
      TimeOfDay notificationTime = settings.tommorowNotificationTime();
      DateTime now = DateTime.now();
      DateTime notificationDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        notificationTime.hour,
        notificationTime.minute,
      );

      // if the notification is being set up after it would come today, it will be set to come tommorow
      if (notificationDateTime.isBefore(now)) {
        notificationDateTime = notificationDateTime.add(const Duration(
          days: 1,
        ));
      }

      schedule = notificationDateTime;
    }

    _scheduleNotificationForDay(
      schedule: schedule,
      showSnackbar: showSnackbar,
    );
  }

  // schedules notification with info about tommorrow (doesn't need to be provided) for provided date
  static void _scheduleNotificationForDay({
    Function(String text)? showSnackbar,
    required DateTime? schedule,
  }) async {
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      return;
    }

    NotificationCalendar? notificationCalendar;
    if (schedule != null) {
      notificationCalendar = NotificationCalendar.fromDate(date: schedule);
    }
    schedule ??= DateTime.now();

    String notificationText = '';
    String examsList = '';
    String homeworksList = '';
    var examsByDate = ExamService().sortByDate();
    var hwByDate = HomeworkService().sortByDate();

    DateTime tommorowDate =
        DateTime(schedule.year, schedule.month, schedule.day)
            .add(const Duration(days: 1));

    List<ExamDTO> examsForTommorow = examsByDate[tommorowDate] ?? [];
    List<HomeworkDTO> hwsForTommorow = hwByDate[tommorowDate] ?? [];

    // creates text for notification for exam
    for (int i = 0; i < examsForTommorow.length; i++) {
      ExamDTO exam = examsForTommorow[i];
      String? subject = exam.subject?.shortcut.sanitizeHtml();

      String examText =
          '-- ${Priority(exam.priority, null).htmlIcon} ${subject != null ? '$subject:' : ''} ${exam.text.sanitizeHtml()}';

      examsList += '$examText<br>';
    }

    // creates text about hw
    hwsForTommorow.sort(
        (a, b) => (a.completion == b.completion ? 0 : (a.completion ? 1 : -1)));
    for (int i = 0; i < hwsForTommorow.length; i++) {
      HomeworkDTO hw = hwsForTommorow[i];
      String? subject = hw.subject?.shortcut.sanitizeHtml();

      String hwText =
          '--  ${hw.completion ? '&#10003<i>' : ''}${Priority(hw.priority, null).htmlIcon} ${subject != null ? '$subject:' : ''} ${hw.text.sanitizeHtml()}</i>';

      homeworksList += '$hwText<br>';
    }

    notificationText =
        '${examsForTommorow.isEmpty ? 'No exams tommorrow' : '<b>Exams:</b>'} <br> $examsList <br> ${hwsForTommorow.isEmpty ? 'No homeworks for tommorrow' : '<b>Homeworks:</b>'} <br> $homeworksList';

    AwesomeNotifications()
        .cancelSchedulesByChannelKey('tommorrow_channel_group');

    AwesomeNotifications().createNotification(
      schedule: notificationCalendar,
      content: NotificationContent(
        id: 11,
        channelKey: 'tommorrow_channel',
        title: 'Tommorrow:',
        body: notificationText,
        autoDismissible: false,
        category: NotificationCategory.Reminder,
        actionType: ActionType.DisabledAction,
        notificationLayout: NotificationLayout.BigText,
      ),
    );

    debugPrintStack(
        label:
            '\u001b[1;42m\u001b[1;30mTommorrow notification scheduled for: ${schedule.toString()}');
    if (showSnackbar != null) {
      showSnackbar(
          'Next notification will arrive ${schedule.isSameDay(DateTime.now()) ? 'today' : 'tommorrow'} at around ${schedule.hour}:${schedule.minuteStartingWithZero()}');
    }
  }

  static bool isCompatiblePlatform() {
    if (Platform.isAndroid || Platform.isIOS) {
      return true;
    }
    return false;
  }

  // returns true if notifications are enabled, if they arent the user is taken to setting/shown request to allow them
  static Future<bool> getPermission(BuildContext context) async {
    if (!isCompatiblePlatform()) {
      return false;
    }

    if (!await AwesomeNotifications().isNotificationAllowed()) {
      await showDialog(
        context: context.mounted == true
            ? context
            : throw Exception('context isn\'mounted: $context'),
        builder: (context) {
          return Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Notification Permission',
                    style: TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                      'If you want this app to send you notifications, you need to grant it permission.'),
                  const Text(
                      'The Grant permission button will take you to app settings from where you can enable all notifications.'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await AwesomeNotifications()
                              .requestPermissionToSendNotifications();
                        },
                        child: const Text('Grant permission'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return await AwesomeNotifications().isNotificationAllowed();
  }
}
