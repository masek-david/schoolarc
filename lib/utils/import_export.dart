import 'dart:convert';

import 'package:school_manager/models/exams/exam_id_model.dart';
import 'package:school_manager/models/homeworks/homework_id_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/tasks_app.dart';

class ImportExport {
  ImportExport(
      {required this.exams, required this.hws, required this.subjects});

  final List<SubjectDTO> subjects;
  final List<ExamWithID> exams;
  final List<HomeworkWithID> hws;
}

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
      'exams': exams
          .map(
            (key, value) => MapEntry(key, value.toJson(key)),
          )
          .values
          .toList(),
      'homework': hws
          .map(
            (key, value) => MapEntry(key, value.toJson(key)),
          )
          .values
          .toList()
    },
  );

  return json;
}

ImportExport import({required String jsonString}) {
  final json = jsonDecode(jsonString);
  final List<ExamWithID> exams = [];
  final List<HomeworkWithID> hws = [];
  final List<SubjectDTO> subjects = [];

  for (var element in (json['subjects'] as List)) {
    subjects.add(SubjectDTO.fromJson(element));
  }
  subjects.sort((a, b) => a.order.compareTo(b.order));

  for (var element in (json['exams'] as List)) {
    exams.add(ExamWithID.fromJson(element));
  }
  exams.sort((a, b) => a.order.compareTo(b.order));

  for (var element in (json['homework'] as List)) {
    hws.add(HomeworkWithID.fromJson(element));
  }
  hws.sort((a, b) => a.order.compareTo(b.order));

  return ImportExport(subjects: subjects, hws: hws, exams: exams);
}
