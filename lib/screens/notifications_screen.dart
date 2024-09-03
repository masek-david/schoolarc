import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.receivedAction});

  final ReceivedAction receivedAction;

  @override
  Widget build(BuildContext context) {
    return Text(receivedAction.buttonKeyInput);
  }
}