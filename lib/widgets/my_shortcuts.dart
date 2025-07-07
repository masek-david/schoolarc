import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/utils/intent/intents.dart';
import 'package:school_manager/utils/task_functions.dart';

class MyShortcuts extends StatelessWidget {
  const MyShortcuts({super.key, required this.child, required this.ref});

  final Widget child;
  final WidgetRef ref;

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
            onInvoke: (intent) => addNewHw(context, ref),
          ),
          NewExamIntent: CallbackAction(
            onInvoke: (intent) => addNewExam(context, ref),
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
