import 'dart:developer';

import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/exams/exam_id_model.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/homework_id_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/provider/firebase_activity_notifier.dart';
import 'package:school_manager/tasks_app.dart';

class FirebaseService {
  FirebaseService({this.ref});

  FirebaseAuth auth = FirebaseAuth.instance;
  WidgetRef? ref;

  late var exams =
      FirebaseDatabase.instance.ref('users/${auth.currentUser?.uid}/e');
  late var homeworks =
      FirebaseDatabase.instance.ref('users/${auth.currentUser?.uid}/h');
  late var subjects =
      FirebaseDatabase.instance.ref('users/${auth.currentUser?.uid}/s');

  bool get isloggedIn {
    return auth.currentUser != null;
  }

  String? get userEmail {
    return auth.currentUser?.email;
  }

  Future<void> testRealtime(Subject subject) async {
    subjects.child(subject.id).update(subject.toFireJson());

    return;
  }

  Future<void> logIn({required String email, required String password}) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);

    exams =
        FirebaseDatabase.instance.ref('users/${auth.currentUser?.uid}/e');
    homeworks = FirebaseDatabase.instance
        .ref('users/${auth.currentUser?.uid}/h');
    subjects = FirebaseDatabase.instance
        .ref('users/${auth.currentUser?.uid}/s');

    return;
  }

  Future<void> logOut() async {
    exams =
        FirebaseDatabase.instance.ref('users/${auth.currentUser?.uid}/e');
    homeworks = FirebaseDatabase.instance
        .ref('users/${auth.currentUser?.uid}/h');
    subjects = FirebaseDatabase.instance
        .ref('users/${auth.currentUser?.uid}/s');

    await auth.signOut();
  }

  Future<void> createUser(
      {required String email, required String password}) async {
    await auth.createUserWithEmailAndPassword(email: email, password: password);
    return;
  }

  // EXAMS
  Stream<ExamWithID> listenExams() {
    final added = exams.onChildAdded.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return ExamWithID.fromFireJson(json);
    });
    final changed = exams.onChildChanged.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return ExamWithID.fromFireJson(json);
    });

    return StreamGroup.merge([added, changed]);
  }

  Future<void> deleteExams(List<Exam> examsToDelete) async {
    if (examsToDelete.isEmpty) return;

    final Map<String, dynamic> updates = {
      for (final element in examsToDelete) element.id: null,
    };

    try {
      await exams.update(updates);
    } on Object catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }
    return;
  }

  Future<void> editExams(List<Exam> examsToUpdate) async {
    if (examsToUpdate.isEmpty) return;

    final updates = {
      for (final element in examsToUpdate) element.id: element.toFireJson()
    };

    try {
      await exams.update(updates);
      ref?.read(firebaseActivityProvider.notifier).modify(2);
    } on Object catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }
    return;
  }

  Future<void> addExam(Exam exam) async {
    try {
      await exams.child(exam.id).update(exam.toFireJson());

      ref?.read(firebaseActivityProvider.notifier).add(2);
    } on Object catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }
    return;
  }

  Future<List<ExamWithID>?> getAllExams() async {
    List<ExamWithID> examsList = [];
    try {
      final snapshot = await exams.get();
      final jsonWhole = Map<String, dynamic>.from(snapshot.value as Map);
      jsonWhole.forEach((key, value) {
        final json = Map<String, dynamic>.from(value as Map);
        json.putIfAbsent('id', () => key);
        examsList.add(ExamWithID.fromFireJson(json));
      });
    } catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }

    return examsList;
  }

  // HOMEWORKS
  Stream<HomeworkWithID> listenHomeworks() {
    final added = homeworks.onChildAdded.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return HomeworkWithID.fromFireJson(json);
    });
    final changed = homeworks.onChildChanged.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return HomeworkWithID.fromFireJson(json);
    });

    return StreamGroup.merge([added, changed]);
  }

  Future<void> deleteHomeworks(List<Homework> hwsToDelete) async {
    if (hwsToDelete.isEmpty) return;

    final Map<String, dynamic> updates = {
      for (final element in hwsToDelete) element.id: null,
    };

    try {
      await homeworks.update(updates);
    } on Object catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }
    return;
  }

  Future<void> editHomeworks(List<Homework> hwsToUpdate) async {
    if (hwsToUpdate.isEmpty) return;

    final updates = {
      for (final element in hwsToUpdate) element.id: element.toFireJson()
    };

    try {
      await homeworks.update(updates);
      ref?.read(firebaseActivityProvider.notifier).modify(1);
    } on Object catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }
    return;
  }

  Future<void> addHomework(Homework homework) async {
    try {
      await homeworks.child(homework.id).update(homework.toFireJson());

      ref?.read(firebaseActivityProvider.notifier).add(1);
    } on Object catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }
    return;
  }

  Future<List<HomeworkWithID>?> getAllHomeworks() async {
    List<HomeworkWithID> homeworksList = [];
    try {
      final snapshot = await homeworks.get();
      final jsonWhole = Map<String, dynamic>.from(snapshot.value as Map);
      jsonWhole.forEach((key, value) {
        final json = Map<String, dynamic>.from(value as Map);
        json.putIfAbsent('id', () => key);
        homeworksList.add(HomeworkWithID.fromFireJson(json));
      });
    } catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }

    return homeworksList;
  }

  // SUBJECTS

  Stream<Subject> listenSubjectsR() {
    final added = subjects.onChildAdded.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return Subject.fromFireJson(json);
    });
    final changed = subjects.onChildChanged.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return Subject.fromFireJson(json);
    });

    return StreamGroup.merge([added, changed]);
  }

  Future<void> deleteSubjects(List<Subject> subjectsToDelete) async {
    if (subjectsToDelete.isEmpty) return;

    final Map<String, dynamic> updates = {
      for (final element in subjectsToDelete) element.id: null,
    };

    try {
      await subjects.update(updates);
    } on Object catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }
    return;
  }

  Future<void> editSubjects(List<Subject> subjectsToUpdate) async {
    if (subjectsToUpdate.isEmpty) return;

    final updates = {
      for (final element in subjectsToUpdate) element.id: element.toFireJson()
    };

    try {
      await subjects.update(updates);
      ref?.read(firebaseActivityProvider.notifier).modify(0);
    } on Object catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }
    return;
  }

  Future<void> addSubject(Subject subject) async {
    try {
      await subjects.child(subject.id).update(subject.toFireJson());

      ref?.read(firebaseActivityProvider.notifier).add(0);
    } on Object catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }
    return;
  }

  Future<List<Subject>> getSubjects() async {
    List<Subject> subjectsList = [];
    try {
      final snapshot = await subjects.get();
      final jsonWhole = Map<String, dynamic>.from(snapshot.value as Map);
      jsonWhole.forEach((key, value) {
        final json = Map<String, dynamic>.from(value as Map);
        json.putIfAbsent('id', () => key);
        subjectsList.add(Subject.fromFireJson(json));
      });
    } catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }

    return subjectsList;
  }
}
