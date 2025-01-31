import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/services/firestore/sync_message.dart';

class FirestoreService {
  FirebaseAuth auth = FirebaseAuth.instance;
  final message = SyncMessage();
  final ProviderContainer _container = ProviderContainer();

  late CollectionReference<Map<String, dynamic>> exams = FirebaseFirestore
      .instance
      .collection('users')
      .doc(auth.currentUser?.uid)
      .collection('exams');
  late CollectionReference<Map<String, dynamic>> homeworks = FirebaseFirestore
      .instance
      .collection('users')
      .doc(auth.currentUser?.uid)
      .collection('homeworks');
  late CollectionReference<Map<String, dynamic>> subjects = FirebaseFirestore
      .instance
      .collection('users')
      .doc(auth.currentUser?.uid)
      .collection('subjects');

  bool get isloggedIn {
    return auth.currentUser != null;
  }

  Future<void> logIn({required String email, required String password}) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);

    exams = FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('exams');
    homeworks = FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('homeworks');
    subjects = FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('subjects');

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

  // returns debug message how many were added
  Future<SyncMessage> syncAll() async {
    message.reset();

    return message;
  }

  Widget getMessage() {
    return message.toWidget();
  }

  // EXAMS

  Stream<QuerySnapshot<Map<String, dynamic>>> examsListenToChanges() {
    return exams.snapshots();
  }

  Future<void> editExams(List<ExamDTO> examsToUpdate) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var exam in examsToUpdate) {
      if (exam.fireId != null) {
        final docRef = exams.doc(exam.fireId);

        printC('batch editing ${exam.toString()}');

        batch.set(docRef, {
          'text': exam.text,
          'deadline': exam.deadline,
          'description': exam.description,
          'priority': exam.priority.index,
          'subjectId': exam.subject?.fireId,
          'isDeleted': exam.isDeleted,
          'timestamp': exam.timestamp,
          'order': exam.order,
        });
      }
    }

    try {
      await batch.commit();
    } on Object catch (e) {
      log(e.toString());
    }
    return;
  }

  Future<void> addExam(ExamDTO exam) async {
    if (exam.fireId != null) {
      try {
        printC('saving hw ${exam.toString()}');
        await exams.doc(exam.fireId).set({
          'text': exam.text,
          'deadline': exam.deadline,
          'description': exam.description,
          'priority': exam.priority.index,
          'subjectId': exam.subject?.fireId,
          'isDeleted': exam.isDeleted,
          'timestamp': exam.timestamp,
          'order': exam.order,
        });
      } on Object catch (e) {
        log(e.toString());
      }
    } else {
      throw 'No fireId for exam: ${exam.toString()}';
    }
    return;
  }

  Future<List<Exam>?> getAllExams() async {
    final query = await exams.get();
    final localSubjects = _container.read(subjectsSortedProvider);

    List<Exam> examsList = [];

    for (var element in query.docs) {
      examsList.add(
        Exam(
          isDeleted: element['isDeleted'],
          timestamp: (element['timestamp'] as Timestamp).toDate(),
          fireId: element.id,
          subjectDbIndex: localSubjects
              .where(
                (exam) => exam.fireId == element['subjectId'],
              )
              .firstOrNull
              ?.dbIndex,
          text: element['text'],
          date: (element['deadline'] as Timestamp).toDate(),
          priority: element['priority'],
          description: element['description'],
          order: element['order'],
        ),
      );
    }

    return examsList;
  }

  // HOMEWORKS

  Stream<QuerySnapshot<Map<String, dynamic>>> homeworksListenToChanges() {
    return homeworks.snapshots();
  }

  Future<void> editHomeworks(List<HomeworkDTO> hwsToUpdate) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var homework in hwsToUpdate) {
      if (homework.fireId != null) {
        final docRef = homeworks.doc(homework.fireId);

        printC('batch editing ${homework.toString()}');

        batch.set(docRef, {
          'text': homework.text,
          'isCompleted': homework.isCompleted,
          'deadline': homework.deadline,
          'description': homework.description,
          'priority': homework.priority.index,
          'subjectId': homework.subject?.fireId,
          'isDeleted': homework.isDeleted,
          'timestamp': homework.timestamp,
          'order': homework.order,
        });
      }
    }

    try {
      await batch.commit();
    } on Object catch (e) {
      log(e.toString());
    }
    return;
  }

  Future<void> addHomework(HomeworkDTO homework) async {
    if (homework.fireId != null) {
      try {
        printC('saving hw ${homework.toString()}');
        await homeworks.doc(homework.fireId).set({
          'text': homework.text,
          'isCompleted': homework.isCompleted,
          'deadline': homework.deadline,
          'description': homework.description,
          'priority': homework.priority.index,
          'subjectId': homework.subject?.fireId,
          'isDeleted': homework.isDeleted,
          'timestamp': homework.timestamp,
          'order': homework.order,
        });
      } on Object catch (e) {
        log(e.toString());
      }
    } else {
      throw 'No fireId for homework: ${homework.toString()}';
    }
    return;
  }

  Future<List<Homework>?> getAllHomeworks() async {
    final query = await homeworks.get();
    final localSubjects = _container.read(subjectsSortedProvider);

    List<Homework> homeworksList = [];

    for (var element in query.docs) {
      homeworksList.add(
        Homework(
          isDeleted: element['isDeleted'],
          timestamp: (element['timestamp'] as Timestamp).toDate(),
          fireId: element.id,
          subjectDbIndex: localSubjects
              .where(
                (homework) => homework.fireId == element['subjectId'],
              )
              .firstOrNull
              ?.dbIndex,
          text: element['text'],
          deadline: (element['deadline'] as Timestamp).toDate(),
          isCompleted: element['isCompleted'],
          priority: element['priority'],
          description: element['description'],
          order: element['order'],
        ),
      );
    }

    return homeworksList;
  }

  // SUBJECTS

  Stream<QuerySnapshot<Map<String, dynamic>>> subjectsListenToChanges() {
    return subjects.snapshots();
  }

  static void printC(String text) {
    print('\u001b[1;96m$text');
  }

  Future<void> editSubjectBatch(List<SubjectDTO> updates) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var subject in updates) {
      if (subject.fireId != null) {
        final docRef = subjects.doc(subject.fireId);

        printC('batch editing subject ${subject.name}: ${subject.order}');

        batch.set(docRef, {
          'name': subject.name,
          'short': subject.shortcut,
          'bakaId': subject.bakaId,
          'isDeleted': subject.isDeleted,
          'timestamp': subject.timestamp,
          'order': subject.order,
        });
      }
    }

    try {
      await batch.commit();
    } on Object catch (e) {
      log(e.toString());
    }
    return;
  }

// TODO use only batch edit
  Future<void> editSubject(String fireId, Subject subject) async {
    printC('editing subject ${subject.name}: ${subject.order}');

    try {
      await subjects.doc(fireId).set({
        'name': subject.name,
        'short': subject.shortcut,
        'bakaId': subject.bakaId,
        'isDeleted': subject.isDeleted,
        'timestamp': subject.timestamp,
        'order': subject.order,
      });
    } on Object catch (e) {
      log(e.toString());
    }
  }

  Future<void> addSubject(SubjectDTO subject) async {
    if (subject.fireId != null) {
      printC('saving subject ${subject.name}: ${subject.order}');

      try {
        await subjects.doc(subject.fireId).set({
          'name': subject.name,
          'short': subject.shortcut,
          'bakaId': subject.bakaId,
          'isDeleted': subject.isDeleted == true,
          'timestamp': subject.timestamp,
          'order': subject.order,
        });
      } on Object catch (error) {
        log(error.toString());
      }
    } else {
      throw 'No fireId for subject: ${subject.toString()}';
    }
    return;
  }

  Future<List<Subject>?> getSubjects() async {
    final query = await subjects.get();

    List<Subject> subjectsList = [];

    for (var element in query.docs) {
      subjectsList.add(
        Subject(
          name: element['name'],
          shortcut: element['short'],
          bakaId: element['bakaId'],
          isDeleted: element['isDeleted'],
          timestamp: (element['timestamp'] as Timestamp).toDate(),
          fireId: element.id,
          order: element['order'],
        ),
      );
    }

    return subjectsList;
  }
}
