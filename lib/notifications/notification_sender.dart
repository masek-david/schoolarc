import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';
import 'package:school_manager/data/exams_data/exam_service.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/data/homeworks_data/hw_service.dart';
import 'package:school_manager/data/user_settings.dart';

class NotificationSender {
  static void sendQuickAdd() {
    _getPermission();
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 10,
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

  static void scheduleNotification() {
    DateTime notificationTime =
        UserSettings.getScheduledTommorowNotificationTime();
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
      print('it will come tommorrow');
      nextScheduledNotificationDate.add(const Duration(days: 1));
    }

    _scheduleNotificationForDay(nextScheduledNotificationDate);
  }

  static void _scheduleNotificationForDay(DateTime date) {
    _getPermission();

    String notificationText = '';
    String examsList = '';
    String homeworksList = '';
    var examsByDate = ExamService().sortByDate();
    var hwByDate = HomeworkService().sortByDate();

    DateTime dayOnlyDate = DateTime(date.year, date.month, date.day);

    List<ExamDTO> examsForTommorow = examsByDate[dayOnlyDate] ?? [];
    List<HomeworkDTO> hwsForTommorow = hwByDate[dayOnlyDate] ?? [];

    for (int i = 0; i < examsForTommorow.length; i++) {
      String examText =
          '-- ${examsForTommorow[i].subject}: ${examsForTommorow[i].text}';
      examsList += '$examText<br>';
    }
    hwsForTommorow.sort(
        (a, b) => (a.completion == b.completion ? 0 : (a.completion ? 1 : -1)));
    for (int i = 0; i < hwsForTommorow.length; i++) {
      String hwText =
          '--  ${hwsForTommorow[i].completion ? '(completed)' : ''} ${hwsForTommorow[i].subject}: ${hwsForTommorow[i].text}';
      homeworksList += '$hwText<br>';
    }

    notificationText =
        '${examsForTommorow.isEmpty ? 'No exams tommorrow' : '<b>Exams:</b>'} <br> $examsList <br> ${hwsForTommorow.isEmpty ? 'No homeworks for tommorrow' : '<b>Homeworks:</b>'} <br> $homeworksList';

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
        body: notificationText, // TODO this must be encoded
        autoDismissible: false,
        category: NotificationCategory.Reminder,
        actionType: ActionType.DisabledAction,
        notificationLayout: NotificationLayout.BigText,
      ),
    );
  }

  static void _getPermission() {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) async {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        await AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }
}
