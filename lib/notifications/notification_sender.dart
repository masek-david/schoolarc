import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';
import 'package:school_manager/data/exams_data/exam_service.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/data/homeworks_data/hw_service.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/extensions/datetime_extension.dart';

class NotificationSender {
  // if not scheduled, it will arrive now and never automatically expire
  static void sendQuickAdd(bool scheduled) async {
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      AwesomeNotifications().cancelSchedulesByChannelKey('persistent_group');
      return;
    }

    NotificationCalendar? schedule;
    Duration? timeoutAfter;

    if (scheduled) {
      SettingsDatabase settings = SettingsDatabase();

      if (settings.quickAddEnabled()) {
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

  // will set new notification about tommorrow
  static void scheduleTommorrowNotification(
      {Function(String text)? showSnackbar}) {
    SettingsDatabase settings = SettingsDatabase();

    if (!settings.tommorrowNotificationEnabled()) {
      AwesomeNotifications()
          .cancelSchedulesByChannelKey('tommorrow_channel_group');
      return;
    }

    TimeOfDay notificationTime = settings.tommorowNotificationTime();
    DateTime now = DateTime.now();
    DateTime nextScheduledNotificationDate = DateTime(
      now.year,
      now.month,
      now.day,
      notificationTime.hour,
      notificationTime.minute,
    );

    // if the notification is being set up after it would come today, it will be set to come tommorow
    if (nextScheduledNotificationDate.isBefore(now)) {
      nextScheduledNotificationDate =
          nextScheduledNotificationDate.add(const Duration(
        days: 1,
      ));
    }

    _scheduleNotificationForDay(
      date: nextScheduledNotificationDate,
      showSnackbar: showSnackbar,
    );
  }

  // schedules notification with info about tommorrow (doesn't need to be provided) for provided date
  static void _scheduleNotificationForDay(
      {Function(String text)? showSnackbar, required DateTime date}) async {
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      return;
    }
    String notificationText = '';
    String examsList = '';
    String homeworksList = '';
    var examsByDate = ExamService().sortByDate();
    var hwByDate = HomeworkService().sortByDate();

    DateTime dateOnlyDay = DateTime(date.year, date.month, date.day);
    DateTime tommorowDate = dateOnlyDay.add(const Duration(days: 1));

    List<ExamDTO> examsForTommorow = examsByDate[tommorowDate] ?? [];
    List<HomeworkDTO> hwsForTommorow = hwByDate[tommorowDate] ?? [];

    for (int i = 0; i < examsForTommorow.length; i++) {
      String examText =
          '-- ${examsForTommorow[i].subject}: ${examsForTommorow[i].text}';
      examText = sanitizeHtml(examText);

      examsList += '$examText<br>';
    }
    hwsForTommorow.sort(
        (a, b) => (a.completion == b.completion ? 0 : (a.completion ? 1 : -1)));
    for (int i = 0; i < hwsForTommorow.length; i++) {
      String hwText =
          '--  ${hwsForTommorow[i].completion ? '(completed)' : ''} ${hwsForTommorow[i].subject}: ${hwsForTommorow[i].text}';
      hwText = sanitizeHtml(hwText);

      homeworksList += '$hwText<br>';
    }

    notificationText =
        '${examsForTommorow.isEmpty ? 'No exams tommorrow' : '<b>Exams:</b>'} <br> $examsList <br> ${hwsForTommorow.isEmpty ? 'No homeworks for tommorrow' : '<b>Homeworks:</b>'} <br> $homeworksList';

    AwesomeNotifications()
        .cancelSchedulesByChannelKey('tommorrow_channel_group');

    AwesomeNotifications().createNotification(
      schedule: NotificationCalendar(
        year: date.year,
        month: date.month,
        day: date.day,
        hour: date.hour,
        minute: date.minute,
      ),
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
            '\u001b[1;42m\u001b[1;30mNotification scheduled for: ${date.toString()}');
    if (showSnackbar != null) {
      showSnackbar(
          'Next notification will arrive ${date.isSameDay(DateTime.now()) ? 'today' : 'tommorrow'} at around ${date.hour}:${date.minuteStartingWithZero()}');
    }
  }

  static void sendSimpleNotification() async {
    if (!await AwesomeNotifications().isNotificationAllowed()) {
      return;
    }

    String text = 'Simple notification';

    text = sanitizeHtml(text);

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 12,
        channelKey: 'tommorrow_channel',
        title: 'testing notification',
        body: text,
        notificationLayout: NotificationLayout.BigText,
      ),
    );
  }

  static String sanitizeHtml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll('\'', '&#39;');
  }

  // returns true if notifications are enabled, if they arent the user is taken to setting/shown request to allow them
  static Future<bool> getPermission(BuildContext context) async {
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
                      'The Grant permission button will take you to app settings from where you will enable all notifications.'),
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
