import 'dart:convert';

import 'package:schoolarc/models/exams/exam_data_model.dart';
import 'package:schoolarc/models/homeworks/hw_data_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/utils/globals.dart';

class ImportExport {
  ImportExport(
      {required this.exams, required this.hws, required this.subjects});

  final List<Subject> subjects;
  final List<ExamData> exams;
  final List<HomeworkData> hws;
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
            (key, value) => MapEntry(key, value.toData(key).toJson()),
          )
          .values
          .toList(),
      'homework': hws
          .map(
            (key, value) => MapEntry(key, value.toData(key).toJson()),
          )
          .values
          .toList()
    },
  );

  return json;
}

ImportExport import({required String jsonString}) {
  final json = jsonDecode(jsonString);
  final List<ExamData> exams = [];
  final List<HomeworkData> hws = [];
  final List<Subject> subjects = [];

  final jsonSubjects = json['subjects'] as List?;
  if (jsonSubjects != null) {
    for (var element in jsonSubjects) {
      subjects.add(Subject.fromJson(element));
    }
    subjects.sort((a, b) => a.order.compareTo(b.order));
  } 

  final jsonExams = json['exams'] as List?;
  if (jsonExams != null) {
    for (var element in jsonExams) {
      exams.add(ExamData.fromJson(element));
    }
    exams.sort((a, b) => a.order.compareTo(b.order));
  }
  final jsonHomework = json['homework'] as List?;
  if (jsonHomework != null) {
    for (var element in jsonHomework) {
      hws.add(HomeworkData.fromJson(element));
    }
    hws.sort((a, b) => a.order.compareTo(b.order));
  }
  return ImportExport(subjects: subjects, hws: hws, exams: exams);
}
