import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:school_manager/data/exams_data/exam_dto_model.dart';
import 'package:school_manager/data/exams_data/exam_service.dart';

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
    _getPermission();

    String notificationText = '';
    var examsByDate = ExamService().sortByDate();

    DateTime now = DateTime.now();
    List<ExamDTO> examsForTommorow =
        examsByDate[DateTime(now.year, now.month, now.day + 1)] ?? [];
    for (int i = 0; i < examsForTommorow.length; i++) {
      notificationText += (examsForTommorow[i].text += '\n');
    }

    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 11,
        channelKey: 'tommorrow_channel',
        title: 'Tommorrow:',
        body: 'Exams: $notificationText',// TODO this must be encoded
        autoDismissible: false,
        locked: true,
        category: NotificationCategory.Status,
        actionType: ActionType.DisabledAction,
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
