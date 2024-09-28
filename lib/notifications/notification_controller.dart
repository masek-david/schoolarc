import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:school_manager/data/exams_data/exam_service.dart';
import 'package:school_manager/data/homeworks_data/hw_service.dart';
import 'package:school_manager/notifications/notification_sender.dart';

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    // Your code goes here

    if (receivedNotification.channelKey == 'tommorrow_channel') {
      NotificationSender.scheduleTommorrowNotification();
    }
    if (receivedNotification.channelKey == 'persistent_channel') {
      NotificationSender.sendQuickAdd(true);
    }
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here

    // on andriod 13+ you can close any notification, so if you close a persistent notification,
    // it will immediately appear again
    // if (receivedAction.channelKey == 'persistent_channel') {
    //   NotificationSender.sendQuickAdd(false);
    // }
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    // TasksApp.navigatorKey.currentState?.pushNamedAndRemoveUntil('/notification-page',
    //         (route) => (route.settings.name != '/notification-page') || route.isFirst,
    //     arguments: receivedAction);


    switch (receivedAction.buttonKeyPressed) {
      case 'homework':
        HomeworkService().saveNewHW(
          date: DateTime.now(),
          priority: 0,
          subject: null,
          text: receivedAction.buttonKeyInput,
        );
      case 'exam':
        ExamService().saveNewExam(
          date: DateTime.now(),
          priority: 0,
          subject: null,
          text: receivedAction.buttonKeyInput,
        );
      default:
    }
    return;
  }
}
