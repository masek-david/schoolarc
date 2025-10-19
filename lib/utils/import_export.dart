import 'dart:convert';

import 'package:schoolarc/models/exams/exam_entity_id_model.dart';
import 'package:schoolarc/models/homeworks/homework_entity_id_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/utils/globals.dart';


class ImportExport {
  ImportExport(
      {required this.exams, required this.hws, required this.subjects});

  final List<Subject> subjects;
  final List<ExamEntityWithID> exams;
  final List<HomeworkEntityWithID> hws;
}

String export() {
  String json = '';

  final subjects = subjectsDb.readDatabase();
  final exams = examsDb.readDatabase();
  final hws = homeworksDb.readDatabase();

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
  final List<ExamEntityWithID> exams = [];
  final List<HomeworkEntityWithID> hws = [];
  final List<Subject> subjects = [];

  for (var element in (json['subjects'] as List)) {
    subjects.add(Subject.fromJson(element));
  }
  subjects.sort((a, b) => a.order.compareTo(b.order));

  for (var element in (json['exams'] as List)) {
    exams.add(ExamEntityWithID
    .fromJson(element));
  }
  exams.sort((a, b) => a.order.compareTo(b.order));

  for (var element in (json['homework'] as List)) {
    hws.add(HomeworkEntityWithID.fromJson(element));
  }
  hws.sort((a, b) => a.order.compareTo(b.order));

  return ImportExport(subjects: subjects, hws: hws, exams: exams);
}
