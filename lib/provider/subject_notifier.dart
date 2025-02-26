import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/provider/firebase_activity_notifier.dart';
import 'package:school_manager/tasks_app.dart';

final subjectsProvider =
    NotifierProvider<SubjectNotifier, Map<int, SubjectDTO>>(
        SubjectNotifier.new);

final subjectsSortedProvider = Provider<List<SubjectDTO>>((ref) {
  final subjects = ref.watch(subjectsProvider);

  // Filter out deleted subjects and sort based on the `order` field.
  return subjects.values.where((subject) => !subject.isDeleted).toList()
    ..sort((a, b) => (a.order).compareTo(b.order));
});

class SubjectNotifier extends Notifier<Map<int, SubjectDTO>> {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? listenFirebase;

  @override
  Map<int, SubjectDTO> build() {
    listenToFirebase();

    return subjectsDbState;
  }

  Map<int, SubjectDTO> get subjectsDbState {
    return subjectsDb.getDatabase().map(
      (key, value) {
        return MapEntry(key, value.convertToDTO(key));
      },
    );
  }

  Future<void> listenToFirebase() async {
    await listenFirebase?.cancel();
    listenFirebase =
        firestoreService.subjectsListenToChanges().listen((event) async {
      ref.read(firebaseActivityProvider.notifier).read(0);

      Map<String, Subject> updatedSubjects = {};

      for (var change in event.docChanges) {
        final doc = change.doc;
        final fireSubject = Subject(
          name: doc['name'],
          shortcut: doc['short'],
          bakaId: doc['bakaId'],
          isDeleted: doc['isDeleted'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          fireId: doc.id,
          order: doc['order'],
        );

        updatedSubjects[doc.id] = fireSubject;
      }

      updatedSubjects.forEach(
        (key, value) async {
          await checkFireSubject(value);
        },
      );
    }, onError: (error) {
      log('error listening to firebase subjects: ${error.toString()}');
    });
  }

  Future<void> syncAll() async {
    await listenToFirebase();
    final fireSubjects = await firestoreService.getSubjects();

    for (final element in fireSubjects) {
      await checkFireSubject(element);
    }

    for (final subject in subjectsDbState.values) {
      if (subject.fireId == null) {
        await edit(subject);
      } else {
        bool isSynced = fireSubjects
                .where(
                  (element) => element.fireId == subject.fireId,
                )
                .firstOrNull !=
            null;

        if (!isSynced) {
          await edit(subject);
        }
      }
    }

    return;
  }

// saves new subject to state, to end if [addToEnd] is true
  Future<SubjectDTO> saveNew(
    Subject subject, {
    bool addToFire = true,
    bool addToEnd = true,
  }) async {
    if (addToEnd) {
      subject.order = subjectsDbState.values
          .where(
            (element) => !element.isDeleted,
          )
          .length;
    }

    if (addToFire) {
      subject = subject.copyWith(fireId: uuid.v4());
    }

    int dbIndex = await subjectsDb.addSubject(subject);

    final SubjectDTO? subjectWithSameOrder = subjectsDbState.values
        .where(
            (element) => element.order == subject.order && !element.isDeleted)
        .firstOrNull;

    // if there is a subject that already has the order of the newly added
    if (!subject.isDeleted) {
      if (subjectWithSameOrder != null && !addToEnd) {
        if (subject.timestamp.millisecondsSinceEpoch <
            subjectWithSameOrder.timestamp.millisecondsSinceEpoch) {
          // if the new one is older, add it after the old
          subject.order++;
          subjectsDb.saveEditedSubject(dbIndex, subject);
        }
        reorder(
          null,
          subject.order,
          subject.convertToDTO(dbIndex),
        );
      }
    }

    state = {...state, dbIndex: subject.convertToDTO(dbIndex)};
    if (addToFire) {
      await firestoreService.addSubject(subject.convertToDTO(0));
    }

    return subject.convertToDTO(dbIndex);
  }

  /// assign timestamp manually, if no fireId, it will add it
  Future<void> edit(
    SubjectDTO editedSubject, {
    bool syncWithFire = true,
    bool reorderAddTimestamp = true,

    /// [checkOrder] false only when editing from [reorder()]
    bool checkOrder = true,
  }) async {
    final old = subjectsDbState[editedSubject.dbIndex]!;

    if (checkOrder) {
      // if now is deleted
      if (editedSubject.isDeleted && !old.isDeleted) {
        reorder(
          old.order,
          null,
          null,
        );
      }
      // if now isnt deleted
      if (!editedSubject.isDeleted && old.isDeleted) {
        reorder(
          null,
          editedSubject.order,
          editedSubject,
        );
      }

      // if order has been changed
      if (old.order != editedSubject.order) {
        await reorder(
          old.order,
          editedSubject.order,
          null,
        );
      }
    }

    state = {...state, editedSubject.dbIndex: editedSubject};
    subjectsDb.saveEditedSubject(
        editedSubject.dbIndex, editedSubject.convert());

    if (syncWithFire) {
      if (editedSubject.fireId != null) {
        await firestoreService.editSubjects(
            [editedSubject.copyWith(fireId: editedSubject.fireId)]);
      } else {
        edit(editedSubject.copyWith(fireId: uuid.v4().toString()));
      }
    }
  }

  /// updates all with changed order, if [oldIndex] is null, it will only be added and [subject] cant be null, if [newIndex] is null, it will be only removed
  Future<void> reorder(
    int? oldIndex,
    int? newIndex,
    SubjectDTO? subject, {
    /// timestamp updated only for the moved subject if [addTimestamp] is true, which is only when it is called from eg. the UI
    bool addTimestamp = false,
  }) async {
    if (oldIndex == null && subject == null) {
      throw '[oldIndex] and [subject] are both null';
    }

    var list = subjectsDbState.values
        .where(
          (element) => !element.isDeleted,
        )
        .toList();

    list.sort((a, b) => a.order.compareTo(b.order));

    if (oldIndex != null) {
      subject =
          list.removeAt(oldIndex < list.length ? oldIndex : list.length - 1);
    }
    if (addTimestamp) {
      subject = subject!.copyWith(timestamp: Timestamp.now());
    }
    if (newIndex != null) {
      list.insert(newIndex > list.length ? list.length : newIndex, subject!);
    }

    final editedSubjects = <int, SubjectDTO>{};

    for (int i = 0; i < list.length; i++) {
      final edited = list[i].copyWith(order: i);
      final oldSubject = subjectsDbState[edited.dbIndex];

      if (edited.order != oldSubject?.order) {
        editedSubjects[edited.dbIndex] = edited;
      }
    }

    state = {...state, ...editedSubjects};

    firestoreService.editSubjects(editedSubjects.values
        .where(
          (element) => element.fireId != null,
        )
        .toList());

    editedSubjects.forEach(
      (key, value) async {
        edit(
          value,
          checkOrder: false,
          syncWithFire: false,
          reorderAddTimestamp: false,
        );
      },
    );
    return;
  }

  void deleteSubject(SubjectDTO subject, {bool nowIsDeleted = true}) {
    edit(subject.copyWith(
      isDeleted: nowIsDeleted,
      timestamp: Timestamp.now(),
    ));
  }

  void revertDelete(SubjectDTO subject) {
    deleteSubject(subject, nowIsDeleted: false);
  }

  void deleteAll() {
    state.forEach(
      (key, value) {
        if (!value.isDeleted) {
          edit(value.copyWith(isDeleted: true));
        }
      },
    );
  }

  /// checks and updates/adds subject from firestore
  Future<void> checkFireSubject(Subject fireSubject) async {
    final localSubject = subjectsDbState.values.where(
      (element) {
        return element.fireId == fireSubject.fireId;
      },
    ).firstOrNull;

    // if it doesnt exist in local, add it
    if (localSubject == null) {
      // print(
      //     '\u001b[1;92madding from fire: ${fireSubject.name}: ${fireSubject.order}');

      await saveNew(
        fireSubject,
        addToFire: false,
        addToEnd: false,
      );
      return;
    }

    final localTime = localSubject.timestamp.toDate();
    final fireTime = fireSubject.timestamp;

    if (fireTime.millisecondsSinceEpoch > localTime.millisecondsSinceEpoch) {
      // print(
      //     '\u001b[1;93mediting from fire: ${fireSubject.name}: ${fireSubject.order}');

      edit(
        fireSubject.convertToDTO(localSubject.dbIndex),
        syncWithFire: false,
        checkOrder: true,
      );
    } else if (fireTime.millisecondsSinceEpoch <
        localTime.millisecondsSinceEpoch) {
      // print(
      //     '\u001b[1;93mediting from hive: ${fireSubject.name}: ${fireSubject.order}');

      firestoreService
          .editSubjects([localSubject.copyWith(fireId: fireSubject.fireId)]);
    } else {
      // print('same date');
    }
    return;
  }
}
