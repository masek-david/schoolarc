
import 'package:flutter/material.dart';

class NewHomeworkIntent extends Intent {
  const NewHomeworkIntent();
}

class NewExamIntent extends Intent {
  const NewExamIntent();
}

class PickPriorityIntent extends Intent {
  const PickPriorityIntent(this.priority);

  final int priority;
}

class PickDateIntent extends Intent {
  const PickDateIntent();
}

class PickSubjectIntent extends Intent {
  const PickSubjectIntent();
}