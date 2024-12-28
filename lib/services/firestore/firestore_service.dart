import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/services/firestore/sync_message.dart';
import 'package:school_manager/tasks_app.dart';

class FirestoreService {
  FirebaseAuth auth = FirebaseAuth.instance;
  final message = SyncMessage();

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

    await syncSubjects();

    await Future.wait([
      syncExams(needsToSyncSubjects: false),
      syncHomeworks(needsToSyncSubjects: false),
    ]);

    return message;
  }

  Widget getMessage(){
    return message.toWidget();
  }

  // EXAMS

  Future<void> syncExams({bool needsToSyncSubjects = true}) async {
    if (needsToSyncSubjects) {
      await syncSubjects();
    }
    final localExams = examService.getAll();
    final fireExams = await _getAllExams();
    final localSubjects = subjectService.getAllSubjects();

    if (fireExams == null) {
      return;
    }

    for (var localExam in localExams) {
      final fireExamWithCorrectId = fireExams.where(
        (fireHw) {
          return fireHw.fireId == localExam.fireId;
        },
      );

      // if it doesnt exist add it to firestore
      if (fireExamWithCorrectId.isEmpty) {
        message.examAddHive++;
        final newFireExam = await addExam(localExam);

        if (newFireExam == null) {
          break;
        }

        await examService.edit(
          localExam.copyWith(fireId: newFireExam.id).convert(),
          localExam.dbIndex,
        );
        // if it exists check which one is newer, override the old one, if at the same time nothing
      } else {
        final localTime = localExam.timestamp.toDate();
        final fireExam = fireExamWithCorrectId.first;
        final fireTime = fireExam.timestamp;

        if (fireTime.millisecondsSinceEpoch >
            localTime.millisecondsSinceEpoch) {
          message.examEditFire++;

          examService.edit(
            fireExam.copyWith(
              subjectDbIndex: localSubjects
                  .where(
                    (element) => element.dbIndex == fireExam.subjectDbIndex,
                  )
                  .firstOrNull
                  ?.dbIndex,
              fireId: localExam.fireId,
            ),
            localExam.dbIndex,
          );
        } else if (fireTime.millisecondsSinceEpoch <
            localTime.millisecondsSinceEpoch) {
          message.examEditHive++;
          await editExam(fireExam.fireId!, localExam);
        }
      }
    }

    for (var fireExam in fireExams) {
      if (localExams.where(
        (localExam) {
          return localExam.fireId == fireExam.fireId;
        },
      ).isEmpty) {
        message.examAddFire++;
        await examService.saveNew(
          fireExam.copyWith(
            subjectDbIndex: localSubjects
                .where(
                  (element) => element.dbIndex == fireExam.subjectDbIndex,
                )
                .firstOrNull
                ?.dbIndex,
          ),
        );
      }
    }

    return;
  }

  Future<void> editExam(String fireId, ExamDTO exam) async {
    return exams.doc(fireId).update({
      'text': exam.text,
      'isCompleted': exam.completion,
      'deadline': exam.deadline,
      'description': exam.description,
      'priority': exam.priority.index,
      'subjectId': exam.subject?.fireId,
      'isDeleted': exam.isDeleted,
      'timestamp': exam.timestamp,
    });
  }

  Future<DocumentReference<Map<String, dynamic>>>? addExam(ExamDTO exam) {
    return exams.add({
      'text': exam.text,
      'isCompleted': exam.completion,
      'deadline': exam.deadline,
      'description': exam.description,
      'priority': exam.priority.index,
      'subjectId': exam.subject?.fireId,
      'isDeleted': exam.isDeleted,
      'timestamp': exam.timestamp,
    });
  }

  Future<List<Exam>?> _getAllExams() async {
    final query = await exams.get();
    final localSubjects = subjectService.getAllSubjects();

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
          completion: element['isCompleted'],
          priority: element['priority'],
          description: element['description'],
        ),
      );
    }

    return examsList;
  }

  // HOMEWORKS

  Future<void> syncHomeworks({bool needsToSyncSubjects = true}) async {
    if (needsToSyncSubjects) {
      await syncSubjects();
    }
    final localHomeworks = homeworkService.getAll();
    final fireHomeworks = await _getAllHomeworks();
    final localSubjects = subjectService.getAllSubjects();

    if (fireHomeworks == null) {
      return;
    }

    for (var localHomework in localHomeworks) {
      final fireHomeworkWithCorrectId = fireHomeworks.where(
        (fireHw) {
          return fireHw.fireId == localHomework.fireId;
        },
      );

      // if it doesnt exist add it to firestore
      if (fireHomeworkWithCorrectId.isEmpty) {
        message.hwAddHive++;
        final newFireHw = await addHomework(localHomework);

        if (newFireHw == null) {
          break;
        }

        await homeworkService.edit(
          localHomework.copyWith(fireId: newFireHw.id).convert(),
          localHomework.dbIndex,
        );
        // if it exists check which one is newer, override the old one, if at the same time nothing
      } else {
        final localTime = localHomework.timestamp.toDate();
        final fireHw = fireHomeworkWithCorrectId.first;
        final fireTime = fireHw.timestamp;

        if (fireTime.millisecondsSinceEpoch >
            localTime.millisecondsSinceEpoch) {
          message.hwEditFire++;

          homeworkService.edit(
            fireHw.copyWith(
              subjectDbIndex: localSubjects
                  .where(
                    (element) => element.dbIndex == fireHw.subjectDbIndex,
                  )
                  .firstOrNull
                  ?.dbIndex,
              fireId: localHomework.fireId,
            ),
            localHomework.dbIndex,
          );
        } else if (fireTime.millisecondsSinceEpoch <
            localTime.millisecondsSinceEpoch) {
          message.hwEditHive++;
          await editHomework(fireHw.fireId!, localHomework);
        }
      }
    }

    for (var fireHw in fireHomeworks) {
      if (localHomeworks.where(
        (localHw) {
          return localHw.fireId == fireHw.fireId;
        },
      ).isEmpty) {
        message.hwAddFire++;
        await homeworkService.saveNew(
          fireHw.copyWith(
            subjectDbIndex: localSubjects
                .where(
                  (element) => element.dbIndex == fireHw.subjectDbIndex,
                )
                .firstOrNull
                ?.dbIndex,
          ),
        );
      }
    }

    return;
  }

  Future<void> editHomework(String fireId, HomeworkDTO homework) async {
    return homeworks.doc(fireId).update({
      'text': homework.text,
      'isCompleted': homework.completion,
      'deadline': homework.deadline,
      'description': homework.description,
      'priority': homework.priority.index,
      'subjectId': homework.subject?.fireId,
      'isDeleted': homework.isDeleted,
      'timestamp': homework.timestamp,
    });
  }

  Future<DocumentReference<Map<String, dynamic>>>? addHomework(
      HomeworkDTO homework) {
    return homeworks.add({
      'text': homework.text,
      'isCompleted': homework.completion,
      'deadline': homework.deadline,
      'description': homework.description,
      'priority': homework.priority.index,
      'subjectId': homework.subject?.fireId,
      'isDeleted': homework.isDeleted,
      'timestamp': homework.timestamp,
    });
  }

  Future<List<Homework>?> _getAllHomeworks() async {
    final query = await homeworks.get();
    final localSubjects = subjectService.getAllSubjects();

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
          completion: element['isCompleted'],
          priority: element['priority'],
          description: element['description'],
        ),
      );
    }

    return homeworksList;
  }

  // SUBJECTS

  Future<void> syncSubjects() async {
    final fireSubjects = await _getSubjects();
    final localSubjects = subjectService.getAllSubjects();

    if (fireSubjects == null) {
      return;
    }

    for (var localSubject in localSubjects) {
      final fireSubjectsWithCorrectId = fireSubjects.where(
        (fireSubject) {
          return fireSubject.fireId == localSubject.fireId;
        },
      );

      // if it doesnt exist in firebase add it there and save its new fireId
      if (fireSubjectsWithCorrectId.isEmpty) {
        message.subAddHive++;
        final newFireSubject = await addSubject(localSubject);

        if (newFireSubject == null) {
          break;
        }

        /// add fireId to local subject
        subjectService
            .editSubject(localSubject.copyWith(fireId: newFireSubject.id));

        // if it exists check which one is newer, override the old one, if at the same time nothing
      } else {
        final localTime = localSubject.timestamp.toDate();
        final fireSubject = fireSubjectsWithCorrectId.first;
        final fireTime = fireSubject.timestamp;

        if (fireTime.millisecondsSinceEpoch >
            localTime.millisecondsSinceEpoch) {
          message.subEditFire++;

          subjectService.editSubject(
            fireSubject
                .copyWith(timestamp: fireSubject.timestamp)
                .convertToDTO(localSubject.dbIndex),
          );
        } else if (fireTime.millisecondsSinceEpoch <
            localTime.millisecondsSinceEpoch) {
          message.subEditHive++;

          await editSubject(fireSubject.fireId!, localSubject.convert());
        }
      }
    }

    for (var fireSubject in fireSubjects) {
      if (localSubjects.where(
        (localSubject) {
          return localSubject.fireId == fireSubject.fireId;
        },
      ).isEmpty) {
        message.subAddFire++;
        await subjectService.addNewSubject(fireSubject);
      }
    }

    return;
  }

  Future<void> editSubject(String fireId, Subject subject) async {
    await subjects.doc(fireId).update({
      'name': subject.name,
      'short': subject.shortcut,
      'bakaId': subject.bakaId,
      'isDeleted': subject.isDeleted,
      'timestamp': subject.timestamp,
    });
  }

  Future<DocumentReference<Map<String, dynamic>>>? addSubject(
      SubjectDTO subject) {
    return subjects.add({
      'name': subject.name,
      'short': subject.shortcut,
      'bakaId': subject.bakaId,
      'isDeleted': subject.isDeleted == true,
      'timestamp': subject.timestamp,
    });
  }

  Future<List<Subject>?> _getSubjects() async {
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
        ),
      );
    }

    return subjectsList;
  }
}
