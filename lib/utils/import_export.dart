import 'dart:convert';

import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/tasks_app.dart';

String export() {
  String json = '';

  final subjects = subjectsDb.getDatabase();
  final exams = examsDb.getDatabase();
  final hws = homeworksDb.getDatabase();

  json = jsonEncode(
    {
      'subjects': subjects.values
          .map(
            (value) => value.toJson(),
          )
          .toList(),
      'exams': exams.values
          .map(
            (value) => value.toJson(subjects),
          )
          .toList(),
      'homework': hws.values
          .map(
            (value) => value.toJson(subjects),
          )
          .toList(),
    },
  );

  return json;
}

Map<String, dynamic> import({required String jsonString}) {
  final json = jsonDecode(jsonString);
  final List<Exam> exams = [];
  final List<Homework> hws = [];
  final List<Subject> subjects = [];

  for (var element in (json['subjects'] as List)) {
    subjects.add(Subject.fromJson(element));
  }
  for (var element in (json['exams'] as List)) {
    exams.add(Exam.fromJson(element));
  }
  for (var element in (json['homework'] as List)) {
    hws.add(Homework.fromJson(element));
  }

  return {'exams': exams, 'homework': hws, 'subjects': subjects};
}
