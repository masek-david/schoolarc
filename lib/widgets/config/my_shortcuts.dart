import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolarc/features/tasks/task_functions.dart';
import 'package:schoolarc/utils/intent/intents.dart';

class MyShortcuts extends StatelessWidget {
  const MyShortcuts({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyH):
            const NewHomeworkIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyE):
            const NewExamIntent(),
      },
      child: Actions(
        actions: {
          NewHomeworkIntent: CallbackAction(
            onInvoke: (intent) => addNewHw(context),
          ),
          NewExamIntent: CallbackAction(
            onInvoke: (intent) => addNewExam(context),
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}
