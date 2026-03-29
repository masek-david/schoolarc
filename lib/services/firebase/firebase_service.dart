import 'dart:convert';
import 'dart:developer';

import 'package:async/async.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/exams/exam_data_model.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/homeworks/hw_data_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/provider/firebase/firebase_activity_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

const _printLogs = false;

final firebaseLoginProvider = StreamProvider<User?>(
  (ref) => FirebaseAuth.instance.userChanges(),
);

final firebaseLoginBoolProvider = Provider<AsyncValue<bool>>(
  (ref) => ref.watch(firebaseLoginProvider).whenData((user) => user != null),
);

class FirebaseService {
  FirebaseService() {
    _refLocation();
  }

  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance;

  late DatabaseReference _exams;
  late DatabaseReference _homeworks;
  late DatabaseReference _subjects;

  User? get user {
    return _auth.currentUser;
  }

  bool get hasUser {
    return _auth.currentUser != null;
  }

  bool get needsVerification {
    return _auth.currentUser?.emailVerified == false;
  }

  Future<DataSnapshot> getAppInfo() {
    return _database.ref('app_info').get();
  }

  void _refLocation() {
    _exams = _database.ref('users/${_auth.currentUser?.uid}/e');
    _homeworks = _database.ref(
      'users/${_auth.currentUser?.uid}/h',
    );
    _subjects = _database.ref(
      'users/${_auth.currentUser?.uid}/s',
    );
  }

  Future<void> logIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _refLocation();
    } on FirebaseAuthException catch (e) {
      throw ApiException(e.message ?? 'Error');
    }
  }

  Future<void> logOut() async {
    await _auth.signOut();

    _refLocation();
    return;
  }

  Future<User?> createUser({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final user = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    _refLocation();
    await saveNickname(nickname);
    return user.user;
  }

  /// Sends verification email to the user
  Future<void> sendVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> changeEmail({
    required String password,
    required String newEmail,
  }) async {
    if (_auth.currentUser == null) {
      throw AuthException(.noUser);
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: _auth.currentUser!.email ?? '',
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw ApiException(e.message ?? 'Error');
    }

    try {
      _auth.currentUser!.verifyBeforeUpdateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw ApiException(e.message ?? 'Error');
      // This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String password,
  }) async {
    if (_auth.currentUser == null) {
      throw AuthException(.noUser);
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: _auth.currentUser!.email ?? '',
        password: oldPassword,
      );
    } on FirebaseAuthException catch (e) {
      throw ApiException(e.message ?? 'Error');
    }

    //Pass in the password to updatePassword.
    try {
      _auth.currentUser!.updatePassword(password);
    } on FirebaseAuthException catch (e) {
      throw ApiException(e.message ?? 'Error');
      // This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
    }
  }

  /// Deletes all data and account, signs out
  Future<void> deleteAllData({required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _auth.currentUser!.email ?? '',
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw ApiException(e.message ?? 'Error');
    }
    try {
      await _exams.remove();
      await _homeworks.remove();
      await _subjects.remove();
      await _auth.currentUser?.delete();
      await logOut();
    } on FirebaseAuthException catch (e) {
      throw ApiException(e.message ?? 'Error');
    }
    return;
  }

  Future<void> getAllData(BuildContext context) async {
    final uid = _auth.currentUser!.uid;
    final ref = _database.ref('users/$uid');
    final loc = context.loc;

    final snapshot = await ref.get();
    if (snapshot.exists) {
      final userData = snapshot.value;

      final exportData = {
        "profile": {
          "nickname": snapshot.child('n').value,
          "uid": _auth.currentUser!.uid,
          "email": _auth.currentUser!.email,
        },
        "data": userData,
      };
      final exportJson = jsonEncode(exportData);

      await FilePicker.platform.saveFile(
        dialogTitle: loc.chooseSaveLocation,
        type: FileType.custom,
        allowedExtensions: ['json'],
        fileName: 'schoolarc_cloud_data_export.json',
        bytes: utf8.encode(exportJson),
      );
    }
  }

  Future<String>? getNickname() async {
    final user = _auth.currentUser;
    if (user == null) return '';

    final snapshot = await _database.ref('users/${user.uid}/n').get();
    return snapshot.value as String;
  }

  Future<void> saveNickname(String name) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _database.ref('users/${user.uid}/n').set(name);
  }

  // EXAMS
  Stream<ExamData> listenExams() {
    if (_auth.currentUser == null) return const Stream.empty();

    final added = _exams.onChildAdded.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return ExamData.fromFireJson(json);
    });
    final changed = _exams.onChildChanged.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return ExamData.fromFireJson(json);
    });

    return StreamGroup.merge([added, changed]);
  }

  Future<void> deleteExams(List<ExamData> examsToDelete) async {
    if (examsToDelete.isEmpty) return;
    if (_auth.currentUser == null) return;

    final Map<String, dynamic> updates = {
      for (final element in examsToDelete) element.id: null,
    };

    try {
      await _exams.update(updates);
    } catch (e, st) {
      logsService.save('$e\n$st');
      if (_printLogs) log('$e\n$st');
    }
    return;
  }

  Future<void> updateExams(List<ExamData> examsToUpdate, {Ref? ref}) async {
    if (examsToUpdate.isEmpty) return;
    if (_auth.currentUser == null) return;

    final updates = {
      for (final element in examsToUpdate) element.id: element.toFireJson(),
    };

    try {
      await _exams.update(updates);
      ref?.read(firebaseActivityProvider.notifier).modify(2);
    } catch (e, st) {
      logsService.save('$e\n$st');
      if (_printLogs) log('$e\n$st');
    }
    return;
  }

  Future<void> createExam(ExamData exam, {Ref? ref}) async {
    if (_auth.currentUser == null) return;
    try {
      await _exams.child(exam.id).update(exam.toFireJson());

      ref?.read(firebaseActivityProvider.notifier).add(2);
    } catch (e, st) {
      logsService.save('$e\n$st');
      if (_printLogs) log('$e\n$st');
    }
    return;
  }

  Future<List<ExamData>?> getAllExams() async {
    if (_auth.currentUser == null) return null;
    List<ExamData> examsList = [];
    try {
      final snapshot = await _exams.get();
      final jsonWhole = Map<String, dynamic>.from(snapshot.value as Map);
      jsonWhole.forEach((key, value) {
        final json = Map<String, dynamic>.from(value as Map);
        json.putIfAbsent('id', () => key);
        examsList.add(ExamData.fromFireJson(json));
      });
    } catch (e, st) {
      logsService.save('$e\n$st');
      if (_printLogs) log('$e\n$st');
    }

    return examsList;
  }

  // HOMEWORKS
  Stream<HomeworkData> listenHomeworks() {
    if (_auth.currentUser == null) return const Stream.empty();

    final added = _homeworks.onChildAdded.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return HomeworkData.fromFireJson(json);
    });
    final changed = _homeworks.onChildChanged.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return HomeworkData.fromFireJson(json);
    });

    return StreamGroup.merge([added, changed]);
  }

  Future<void> deleteHomeworks(List<HomeworkData> hwsToDelete) async {
    if (hwsToDelete.isEmpty) return;
    if (_auth.currentUser == null) return;

    final Map<String, dynamic> updates = {
      for (final element in hwsToDelete) element.id: null,
    };

    try {
      await _homeworks.update(updates);
    } catch (e, st) {
      logsService.save('$e\n$st');
      if (_printLogs) log('$e\n$st');
    }
    return;
  }

  Future<void> updateHw(List<HomeworkData> hwsToUpdate, {Ref? ref}) async {
    if (hwsToUpdate.isEmpty) return;
    if (_auth.currentUser == null) return;

    final updates = {
      for (final element in hwsToUpdate) element.id: element.toFireJson(),
    };

    try {
      await _homeworks.update(updates);
      ref?.read(firebaseActivityProvider.notifier).modify(1);
    } catch (e, st) {
      logsService.save('$e\n$st');
      if (_printLogs) log('$e\n$st');
    }
    return;
  }

  Future<void> createHw(HomeworkData homework, {Ref? ref}) async {
    if (_auth.currentUser == null) return;
    try {
      await _homeworks.child(homework.id).update(homework.toFireJson());

      ref?.read(firebaseActivityProvider.notifier).add(1);
    } catch (e, st) {
      logsService.save('$e\n$st');
      if (_printLogs) log('$e\n$st');
    }
    return;
  }

  Future<List<HomeworkData>?> getAllHomeworks() async {
    if (_auth.currentUser == null) return null;
    List<HomeworkData> homeworksList = [];
    try {
      final snapshot = await _homeworks.get();
      final jsonWhole = Map<String, dynamic>.from(snapshot.value as Map);
      jsonWhole.forEach((key, value) {
        final json = Map<String, dynamic>.from(value as Map);
        json.putIfAbsent('id', () => key);
        homeworksList.add(HomeworkData.fromFireJson(json));
      });
    } catch (e, st) {
      logsService.save('$e\n$st');
      if (_printLogs) log('$e\n$st');
    }

    return homeworksList;
  }

  // SUBJECTS

  Stream<Subject> listenSubjects() {
    if (_auth.currentUser == null) return const Stream.empty();
    final added = _subjects.onChildAdded.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return Subject.fromFireJson(json);
    });
    final changed = _subjects.onChildChanged.map((event) {
      final json = Map<String, dynamic>.from(event.snapshot.value as Map);
      json.putIfAbsent('id', () => event.snapshot.key);
      return Subject.fromFireJson(json);
    });

    return StreamGroup.merge([added, changed]);
  }

  Future<void> deleteSubjects(List<Subject> subjectsToDelete) async {
    if (subjectsToDelete.isEmpty) return;
    if (_auth.currentUser == null) return;

    final Map<String, dynamic> updates = {
      for (final element in subjectsToDelete) element.id: null,
    };

    try {
      await _subjects.update(updates);
    } catch (e, st) {
      logsService.save('$e\n$st');
      if (_printLogs) log('$e\n$st');
    }
    return;
  }

  Future<void> updateSubjects(
    List<Subject> subjectsToUpdate, {
    Ref? ref,
  }) async {
    if (subjectsToUpdate.isEmpty) return;
    if (_auth.currentUser == null) return;

    final updates = {
      for (final element in subjectsToUpdate) element.id: element.toFireJson(),
    };

    try {
      await _subjects.update(updates);
      ref?.read(firebaseActivityProvider.notifier).modify(0);
    } catch (e, st) {
      logsService.save('$e\n$st');
      if (_printLogs) log('$e\n$st');
    }
    return;
  }

  Future<void> createSubject(Subject subject, {Ref? ref}) async {
    if (_auth.currentUser == null) return;
    try {
      await _subjects.child(subject.id).update(subject.toFireJson());

      ref?.read(firebaseActivityProvider.notifier).add(0);
    } catch (e, st) {
      logsService.save('$e\n$st');
      if (_printLogs) log('$e\n$st');
    }
    return;
  }

  Future<List<Subject>?> getSubjects() async {
    if (_auth.currentUser == null) return null;
    List<Subject> subjectsList = [];
    try {
      final snapshot = await _subjects.get();
      final jsonWhole = Map<String, dynamic>.from(snapshot.value as Map);
      jsonWhole.forEach((key, value) {
        final json = Map<String, dynamic>.from(value as Map);
        json.putIfAbsent('id', () => key);
        subjectsList.add(Subject.fromFireJson(json));
      });
    } catch (e, st) {
      logsService.save('$e\n$st');
      if (_printLogs) log('$e\n$st');
    }

    return subjectsList;
  }
}
