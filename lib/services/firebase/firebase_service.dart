import 'dart:developer';

import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/exams/exam_id_model.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/homeworks/homework_id_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/provider/firebase_activity_notifier.dart';

class FirebaseService {
  FirebaseService({this.ref});

  FirebaseAuth auth = FirebaseAuth.instance;
  WidgetRef? ref;

  late var exams =
      FirebaseDatabase.instance.ref('users/${auth.currentUser?.uid}/exams');
  late var homeworks =
      FirebaseDatabase.instance.ref('users/${auth.currentUser?.uid}/homeworks');
  late var subjects =
      FirebaseDatabase.instance.ref('users/${auth.currentUser?.uid}/subjects');

  bool get isloggedIn {
    return auth.currentUser != null;
  }

  String? get userEmail {
    return auth.currentUser?.email;
  }

  Future<void> testRealtime(SubjectDTO subject) async {
    subjects.child(subject.id).update(subject.toFireJson());

    return;
  }

  Future<void> logIn({required String email, required String password}) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);

    exams =
        FirebaseDatabase.instance.ref('users/${auth.currentUser?.uid}/exams');
    homeworks = FirebaseDatabase.instance
        .ref('users/${auth.currentUser?.uid}/homeworks');
    subjects = FirebaseDatabase.instance
        .ref('users/${auth.currentUser?.uid}/subjects');

    return;
  }

  Future<void> logOut() async {
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

  Future<void> deleteExams(List<ExamDTO> examsToDelete) async {
    if (examsToDelete.isEmpty) return;

    final Map<String, dynamic> updates = {
      for (final element in examsToDelete) element.id: null,
    };

    try {
      await exams.update(updates);
    } on Object catch (e) {
      log(e.toString());
    }
    return;
  }

  Future<void> editExams(List<ExamDTO> examsToUpdate) async {
    if (examsToUpdate.isEmpty) return;

    final updates = {
      for (final element in examsToUpdate) element.id: element.toFireJson()
    };

    try {
      await exams.update(updates);
      ref?.read(firebaseActivityProvider.notifier).modify(2);
    } on Object catch (e) {
      log(e.toString());
    }
    return;
  }

  Future<void> addExam(ExamDTO exam) async {
    try {
      await exams.child(exam.id).update(exam.toFireJson());

      ref?.read(firebaseActivityProvider.notifier).add(2);
    } on Object catch (error) {
      log(error.toString());
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

  Future<void> deleteHomeworks(List<HomeworkDTO> hwsToDelete) async {
    if (hwsToDelete.isEmpty) return;

    final Map<String, dynamic> updates = {
      for (final element in hwsToDelete) element.id: null,
    };

    try {
      await homeworks.update(updates);
    } on Object catch (e) {
      log(e.toString());
    }
    return;
  }

  Future<void> editHomeworks(List<HomeworkDTO> hwsToUpdate) async {
    if (hwsToUpdate.isEmpty) return;

    final updates = {
      for (final element in hwsToUpdate) element.id: element.toFireJson()
    };

    try {
      await homeworks.update(updates);
      ref?.read(firebaseActivityProvider.notifier).modify(1);
    } on Object catch (e) {
      log(e.toString());
    }
    return;
  }

  Future<void> addHomework(HomeworkDTO homework) async {
    try {
      await homeworks.child(homework.id).update(homework.toFireJson());

      ref?.read(firebaseActivityProvider.notifier).add(1);
    } on Object catch (error) {
      log(error.toString());
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
      log(e.toString());
    }

    return homeworksList;
  }

  // SUBJECTS

  Stream<SubjectDTO> listenSubjectsR() {
    final added = subjects.onChildAdded.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return SubjectDTO.fromFireJson(json);
    });
    final changed = subjects.onChildChanged.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return SubjectDTO.fromFireJson(json);
    });

    return StreamGroup.merge([added, changed]);
  }

  Future<void> deleteSubjects(List<SubjectDTO> subjectsToDelete) async {
    if (subjectsToDelete.isEmpty) return;

    final Map<String, dynamic> updates = {
      for (final element in subjectsToDelete) element.id: null,
    };

    try {
      await subjects.update(updates);
    } on Object catch (e) {
      log(e.toString());
    }
    return;
  }

  Future<void> editSubjects(List<SubjectDTO> subjectsToUpdate) async {
    if (subjectsToUpdate.isEmpty) return;

    final updates = {
      for (final element in subjectsToUpdate) element.id: element.toFireJson()
    };

    try {
      await subjects.update(updates);
      ref?.read(firebaseActivityProvider.notifier).modify(0);
    } on Object catch (e) {
      log(e.toString());
    }
    return;
  }

  Future<void> addSubject(SubjectDTO subject) async {
    try {
      await subjects.child(subject.id).update(subject.toFireJson());

      ref?.read(firebaseActivityProvider.notifier).add(0);
    } on Object catch (error) {
      log(error.toString());
    }
    return;
  }

  Future<List<SubjectDTO>> getSubjects() async {
    List<SubjectDTO> subjectsList = [];
    try {
      final snapshot = await subjects.get();
      final jsonWhole = Map<String, dynamic>.from(snapshot.value as Map);
      jsonWhole.forEach((key, value) {
        final json = Map<String, dynamic>.from(value as Map);
        json.putIfAbsent('id', () => key);
        subjectsList.add(SubjectDTO.fromFireJson(json));
      });
    } catch (e) {
      log(e.toString());
    }

    return subjectsList;
  }
}
