import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:async/async.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/l10n/my_localization.dart';
import 'package:school_manager/models/exams/exam_id_model.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/exception_model.dart';
import 'package:school_manager/models/homeworks/homework_id_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/provider/firebase_activity_notifier.dart';
import 'package:school_manager/tasks_app.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService(ref: ref);
});

class FirebaseService {
  FirebaseService({required this.ref}) {
    refLocation();
  }

  FirebaseAuth auth = FirebaseAuth.instance;
  Ref? ref;

  late DatabaseReference exams;
  late DatabaseReference homeworks;
  late DatabaseReference subjects;

  bool get isloggedIn {
    return auth.currentUser != null;
  }

  String? get userEmail {
    return auth.currentUser?.email;
  }

  void refLocation() {
    if (!kIsWeb && Platform.isWindows) return;

    exams = FirebaseDatabase.instance.ref('users/${auth.currentUser?.uid}/e');
    homeworks =
        FirebaseDatabase.instance.ref('users/${auth.currentUser?.uid}/h');
    subjects =
        FirebaseDatabase.instance.ref('users/${auth.currentUser?.uid}/s');
  }

  Future<void> logIn({required String email, required String password}) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

      refLocation();
    } on FirebaseAuthException catch (e) {
      final loc = getLocalization();

      if ((e).message == loc.internalError) {
        throw ServiceException(loc.tryAgain);
      }
      throw ServiceException(e.message);
    }

    return;
  }

  Future<void> logOut() async {
    await auth.signOut();

    refLocation();
    return;
  }

  Future<void> createUser(
      {required String email, required String password}) async {
    await auth.createUserWithEmailAndPassword(email: email, password: password);
    refLocation();
    return;
  }

  Future<bool> changePassword(String oldPassword, String password) async {
    final loc = getLocalization();
    if (auth.currentUser == null) {
      throw ServiceException(loc.noUserLoggedIn);
    }

    try {
      await auth.signInWithEmailAndPassword(
        email: auth.currentUser!.email ?? '',
        password: oldPassword,
      );
    } on Object catch (error) {
      throw ServiceException("${loc.cantLogin} $error");
    }

    //Pass in the password to updatePassword.
    auth.currentUser!.updatePassword(password).then((_) {
      return true;
    }).catchError((error) {
      throw ServiceException("${loc.passwordCantBeChanged} $error");
      // This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    });
    return false;
  }

  Future<void> deleteAllData(String password) async {
    final loc = getLocalization();
    try {
      await auth.signInWithEmailAndPassword(
        email: auth.currentUser!.email ?? '',
        password: password,
      );
    } on Object catch (error) {
      throw ServiceException("${loc.cantLogin} $error");
    }
    try {
      await exams.remove();
      await homeworks.remove();
      await subjects.remove();
      await FirebaseAuth.instance.currentUser?.delete();
    } on Object catch (error) {
      throw ServiceException("${loc.cantDeleteData} $error");
    }
    return;
  }

  Future<void> getAllData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseDatabase.instance.ref('users/$uid');

    final snapshot = await ref.get();
    if (snapshot.exists) {
      final userData = snapshot.value;

      final exportData = {
        "profile": {
          "uid": auth.currentUser!.uid,
          "email": auth.currentUser!.email,
        },
        "data": userData
      };
      final exportJson = jsonEncode(exportData);

      await FilePicker.platform.saveFile(
        dialogTitle: getLocalization().chooseSaveLocation,
        type: FileType.custom,
        allowedExtensions: ['json'],
        fileName: 'schoolarc_cloud_data_export.json',
        bytes: utf8.encode(exportJson),
      );
    }
  }

  // EXAMS
  Stream<ExamWithID> listenExams() {
    if (auth.currentUser == null) return const Stream.empty();

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
    if (auth.currentUser == null) return;

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
    if (auth.currentUser == null) return;

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
    if (auth.currentUser == null) return;
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
    if (auth.currentUser == null) return null;
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
    if (auth.currentUser == null) return const Stream.empty();

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
    if (auth.currentUser == null) return;

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
    if (auth.currentUser == null) return;

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
    if (auth.currentUser == null) return;
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
    if (auth.currentUser == null) return null;
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

  Stream<Subject> listenSubjects() {
    if (auth.currentUser == null) return const Stream.empty();
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
    if (auth.currentUser == null) return;

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
    if (auth.currentUser == null) return;

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
    if (auth.currentUser == null) return;
    try {
      await subjects.child(subject.id).update(subject.toFireJson());

      ref?.read(firebaseActivityProvider.notifier).add(0);
    } on Object catch (e) {
      logsService.save(e.toString());
      log(e.toString());
    }
    return;
  }

  Future<List<Subject>?> getSubjects() async {
    if (auth.currentUser == null) return null;
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
