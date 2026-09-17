import 'package:flutter/material.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/task_data_model.dart';

/// This class is used to reopen a dismissed bottom sheet, if the user didn't save edited data
class EditTaskState {
  EditTaskState({
    required this.autoSetDateToNextSubjectDate,
    required this.initialTask,
    required this.isHomework,
  }) : name = TextEditingController(text: initialTask.text),
       description = TextEditingController(text: initialTask.description),
       priority = initialTask.priority,
       subjectId = initialTask.subjectId,
       date = initialTask.date;

  /// The initial values are set to the values of the [initialTask] and are compared to it when asked if they can be discarded
  final TaskData initialTask;

  /// Whether the created task should be saved as a homework, or an exam
  final bool isHomework;

  /// Whether to automatically set the [date] to the next occurance of the subject that has been selected
  ///
  /// Is true by default, will be set to false when the user picks their own date or when they open the sheet from eg. the calendar page
  bool autoSetDateToNextSubjectDate;

  TextEditingController name;
  TextEditingController description;
  int priority;
  String? subjectId;
  Date date;

  void dispose() {
    name.dispose();
    description.dispose();
  }

  bool hasUnsavedData() {
    return initialTask.text != name.text ||
        initialTask.description != description.text ||
        initialTask.priority != priority ||
        initialTask.subjectId != subjectId ||
        initialTask.date != date;
  }

  /// Returns the initial task edited with the current values that the user has edited
  TaskData createTask() {
    return initialTask.copyWith(
      subjectId: subjectId,
      text: name.text,
      description: description.text,
      date: date,
      priority: priority,
      timestamp: DateTime.now().toUtc(),
    );
  }
}