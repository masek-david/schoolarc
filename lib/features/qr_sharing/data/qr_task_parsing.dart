import 'dart:convert';

import 'package:cbor/cbor.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/models/task_model.dart';

class QrParse {
  static Uri toUri(Task task, bool isHomework) {
    final data = CborValue([
      isHomework,
      task.text,
      task.description,
      task.subject?.name,
      task.subject?.shortcut,
      task.subject?.bakaId,
      task.date.toPrimitiveInt(),
      task.priority.index,
    ]);
    final List<int> bytes = cborEncode(data);
    final base64 = base64UrlEncode(bytes);

    return Uri(
      scheme: 'schoolarc',
      host: '',
      queryParameters: {'sh0': base64},
    );
  }

  static Task fromQr(String input, List<Subject> subjects) {
    final inputCleaned = input.substring(input.indexOf('=') + 1);
    final bytes = base64Url.decode(inputCleaned);
    final list = (cbor.decode(bytes).toObject() as List);

    final isHomework = list[0] as bool;
    final text = list[1] as String;
    final description = list[2] as String;
    final subjectName = list[3] as String?;
    final subjectShortcut = list[4] as String?;
    final subjectBakaId = list[5] as String?;
    final date = Date.fromPrimitiveInt(list[6] as int);
    final priority = TaskPriority(list[7] as int);

    Subject? subject;
    if (subjectName != null && subjectShortcut != null) {
      subject =
          subjects
              .where((element) => element.bakaId == subjectBakaId)
              .firstOrNull ??
          subjects
              .where((element) => element.containsText(subjectName))
              .firstOrNull ??
          subjects
              .where((element) => element.containsText(subjectShortcut))
              .firstOrNull;
    }

    if (isHomework) {
      return Homework(
        subject: subject,
        text: text,
        date: date,
        isCompleted: false,
        priority: priority,
        id: '',
        description: description,
        timestamp: DateTime.now(),
        isDeleted: false,
        order: 0,
      );
    } else {
      return Exam(
        subject: subject,
        text: text,
        date: date,
        isCompleted: false,
        priority: priority,
        id: '',
        description: description,
        timestamp: DateTime.now(),
        isDeleted: false,
        order: 0,
      );
    }
  }
}
