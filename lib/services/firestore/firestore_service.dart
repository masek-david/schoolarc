import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/provider/firebase_activity_notifier.dart';
import 'package:school_manager/tasks_app.dart';

class FirestoreService {
  FirestoreService({this.ref});

  FirebaseAuth auth = FirebaseAuth.instance;
  WidgetRef? ref;

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

  String? get userEmail {
    return auth.currentUser?.email;
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

  // EXAMS

  Stream<QuerySnapshot<Map<String, dynamic>>> examsListenToChanges() {
    return exams.snapshots();
  }

  Future<void> editExams(List<ExamDTO> examsToUpdate) async {
    if (examsToUpdate.isEmpty) {
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    for (var exam in examsToUpdate) {
      if (exam.fireId != null) {
        final docRef = exams.doc(exam.fireId);

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
    ref?.read(firebaseActivityProvider.notifier).modify(2);

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
        ref?.read(firebaseActivityProvider.notifier).add(2);
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
    ref?.read(firebaseActivityProvider.notifier).read(2);

    final localSubjects = subjectsDb.getDatabase();

    List<Exam> examsList = [];

    for (var element in query.docs) {
      examsList.add(
        Exam(
          isDeleted: element['isDeleted'],
          timestamp: (element['timestamp'] as Timestamp).toDate(),
          fireId: element.id,
          subjectDbIndex: localSubjects.entries
              .where(
                (entry) => entry.value.fireId == element['subjectId'],
              )
              .firstOrNull
              ?.key,
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
    if (hwsToUpdate.isEmpty) {
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    for (var homework in hwsToUpdate) {
      if (homework.fireId != null) {
        final docRef = homeworks.doc(homework.fireId);

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
    ref?.read(firebaseActivityProvider.notifier).modify(1);

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
        ref?.read(firebaseActivityProvider.notifier).add(1);
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

  Future<List<Homework>?> getAllHomeworks(Map<int, SubjectDTO> subjects) async {
    final query = await homeworks.get();
    ref?.read(firebaseActivityProvider.notifier).read(1);

    Map<String, SubjectDTO> subjectMap = {};
    subjectsDb.getDatabase().forEach(
      (key, value) {
        if (value.fireId != null) {
          subjectMap[value.fireId!] = value.convertToDTO(key);
        }
      },
    );

    List<Homework> homeworksList = [];

    for (var element in query.docs) {
      homeworksList.add(
        Homework(
          isDeleted: element['isDeleted'],
          timestamp: (element['timestamp'] as Timestamp).toDate(),
          fireId: element.id,
          subjectDbIndex: subjectMap[element['subjectId']]?.dbIndex,
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

  Future<void> editSubjects(List<SubjectDTO> updates) async {
    if (updates.isEmpty) {
      return;
    }

    final batch = FirebaseFirestore.instance.batch();

    for (var subject in updates) {
      if (subject.fireId != null) {
        final docRef = subjects.doc(subject.fireId);

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
    ref?.read(firebaseActivityProvider.notifier).modify(0);

    try {
      await batch.commit();
    } on Object catch (e) {
      log(e.toString());
    }
    return;
  }

  Future<void> addSubject(SubjectDTO subject) async {
    if (subject.fireId != null) {
      ref?.read(firebaseActivityProvider.notifier).add(0);

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

  Future<List<Subject>> getSubjects() async {
    final query = await subjects.get();
    ref?.read(firebaseActivityProvider.notifier).read(0);

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
