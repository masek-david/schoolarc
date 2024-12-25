import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/tasks_app.dart';

class FirestoreService {
  FirebaseAuth auth = FirebaseAuth.instance;

  late CollectionReference<Map<String, dynamic>> homeworks = FirebaseFirestore.instance
        .collection('users')
        .doc(auth.currentUser?.uid)
        .collection('homeworks');
  late CollectionReference<Map<String, dynamic>> subjects = FirebaseFirestore
      .instance
      .collection('users')
      .doc(auth.currentUser?.uid)
      .collection('subjects');

  bool get isLoggedIn {
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

      // if it doesnt exist add it
      if (fireSubjectsWithCorrectId.isEmpty) {
        log('adding from hive');
        final newFireSubject = await addSubject(localSubject);

        if (newFireSubject == null) {
          break;
        }

        subjectService
            .editSubject(localSubject.copyWith(fireId: newFireSubject.id));

        // if it exists check which one is newer, override the old one, if at the same time nothing
      } else {
        final localTime = localSubject.timestamp.toDate();
        final fireSubject = fireSubjectsWithCorrectId.first;
        final fireTime = fireSubject.timestamp;

        if (fireTime.millisecondsSinceEpoch >
            localTime.millisecondsSinceEpoch) {
          log('editing from firestore');

          subjectService.editSubject(
            fireSubject.convertToDTO(localSubject.dbIndex),
          );
        } else if (fireTime.millisecondsSinceEpoch <
            localTime.millisecondsSinceEpoch) {
          log('editing from hive');
          await editSubject(fireSubject.fireId!, localSubject.convert());
        } else {
          log('same date');
        }
      }
    }

    for (var fireSubject in fireSubjects) {
      if (localSubjects.where(
        (localSubject) {
          return localSubject.fireId == fireSubject.fireId;
        },
      ).isEmpty) {
        log('adding from firestore');
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
