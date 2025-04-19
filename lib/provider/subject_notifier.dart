import 'dart:async';
import 'dart:developer';

import 'package:riverpod/riverpod.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/models/subjects/subject_entity_model.dart';
import 'package:school_manager/provider/firebase_activity_notifier.dart';
import 'package:school_manager/tasks_app.dart';

final subjectsProvider =
    NotifierProvider<SubjectNotifier, Map<String, Subject>>(
        SubjectNotifier.new);

final subjectsSortedProvider = Provider<List<Subject>>((ref) {
  final subjects = ref.watch(subjectsProvider);

  // Filter out deleted subjects and sort based on the `order` field.
  return subjects.values.where((subject) => !subject.isDeleted).toList()
    ..sort((a, b) => (a.order).compareTo(b.order));
});

final subjectsDeletedProvider = Provider<List<Subject>>(
  (ref) {
    final subjects = ref.watch(subjectsProvider);

    final list = <Subject>[];

    subjects.forEach(
      (key, value) {
        if (value.isDeleted) {
          list.add(value);
        }
      },
    );
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return list;
  },
);

class SubjectNotifier extends Notifier<Map<String, Subject>> {
  StreamSubscription<Subject>? listenFirebase;

  @override
  Map<String, Subject> build() {
    listenToFirebase();

    _checkForDeleted();

    return _dbState;
  }

  Map<String, Subject> get _dbState {
    return subjectsDb.getDatabase();
  }

  Future<void> listenToFirebase() async {
    await listenFirebase?.cancel();

    listenFirebase = firebaseService.listenSubjectsR().listen((event) async {
      ref.read(firebaseActivityProvider.notifier).read(0);

      await checkFireSubject(event);
    }, onError: (error) {
      log('error listening to firebase subjects: ${error.toString()}');
    });
  }

  Future<void> syncAll() async {
    await listenToFirebase();
    final fireSubjects = await firebaseService.getSubjects();

    for (final element in fireSubjects) {
      await checkFireSubject(element);
    }

    for (final subject in _dbState.values) {
      bool isSynced = fireSubjects
              .where(
                (element) => element.id == subject.id,
              )
              .firstOrNull !=
          null;

      if (!isSynced) {
        await edit(subject);
      }
    }

    return;
  }

  /// saves new subject to state, to end if [addToEnd] is true
  Future<Subject> saveNew(
    SubjectEntity subject, {
    // if null, new id is generated
    String? overrideId,
    bool addToFire = true,
    // sets the order to put the task to the end
    bool addToEnd = true,
  }) async {
    if (addToEnd) {
      subject = subject.copyWith(
          order: _dbState.values
              .where(
                (element) => !element.isDeleted,
              )
              .length);
    }

    final id = overrideId ?? uuid.v4();

    await subjectsDb.addSubject(id, subject);

    final Subject? subjectWithSameOrder = _dbState.values
        .where(
            (element) => element.order == subject.order && !element.isDeleted)
        .firstOrNull;

    // if there is a subject that already has the order of the newly added
    if (!subject.isDeleted) {
      if (subjectWithSameOrder != null && !addToEnd) {
        if (subject.timestamp.millisecondsSinceEpoch <
            subjectWithSameOrder.timestamp.millisecondsSinceEpoch) {
          // if the new one is older, add it after the old
          subject = subject.copyWith(order: subject.order + 1);
          subjectsDb.saveEditedSubject(id, subject);
        }
        reorder(
          subject.order,
          subject.convert(id),
        );
      }
    }

    state = {...state, id: subject.convert(id)};
    if (addToFire) {
      await firebaseService.addSubject(subject.convert(id));
    }

    return subject.convert(id);
  }

  /// assign timestamp manually, if no fireId, it will add it
  Future<void> edit(
    Subject editedSubject, {
    bool syncWithFire = true,
    bool reorderAddTimestamp = true,

    /// [checkOrder] false only when editing from [reorder()]
    bool checkOrder = true,
  }) async {
    final old = _dbState[editedSubject.id]!;

    if (checkOrder) {
      // if now is deleted, remove it
      if (editedSubject.isDeleted && !old.isDeleted) {
        reorder(
          null,
          old,
        );
      }
      // if now isnt deleted, add it
      if (!editedSubject.isDeleted && old.isDeleted) {
        reorder(
          editedSubject.order,
          old,
        );
      }

      // if order has been changed, reorder
      if (old.order != editedSubject.order) {
        await reorder(
          editedSubject.order,
          old,
        );
      }
    }

    state = {...state, editedSubject.id: editedSubject};
    subjectsDb.saveEditedSubject(editedSubject.id, editedSubject.convert());

    if (syncWithFire) {
      await firebaseService
          .editSubjects([editedSubject.copyWith(id: editedSubject.id)]);
    }
  }

  /// updates all with changed order,
  /// if [newIndex] is null, it will be only removed
  ///
  /// timestamp updated only for the moved subject if [addTimestamp] is true, which is only when it is called from eg. the UI
  Future<void> reorder(
    // int? oldIndex,
    int? newIndex,
    final Subject originalSubject, {
    bool addTimestamp = false,
  }) async {
    var list = _dbState.values
        .where(
          (element) => !element.isDeleted,
        )
        .toList();

    list.sort((a, b) => a.order.compareTo(b.order));

    list.removeWhere((element) => element.id == originalSubject.id);

    Subject newSubject = originalSubject;
    if (addTimestamp) {
      newSubject = newSubject.copyWith(timestamp: DateTime.now().toUtc());
    }
    if (newIndex != null) {
      list.insert(newIndex > list.length ? list.length : newIndex, newSubject);
    }

    // now the list is final, just save the changes

    final editedSubjects = <String, Subject>{};

    for (int i = 0; i < list.length; i++) {
      final edited = list[i].copyWith(order: i);
      final oldSubject = _dbState[edited.id];

      if (edited.order != oldSubject?.order) {
        editedSubjects[edited.id] = edited;
      }
    }

    editedSubjects.forEach(
      (key, value) {
        subjectsDb.saveEditedSubject(key, value.convert());
      },
    );

    state = {...state, ...editedSubjects};

    await firebaseService.editSubjects(editedSubjects.values.toList());
    return;
  }

  void deleteSubject(Subject subject, {bool nowIsDeleted = true}) {
    edit(subject.copyWith(
      isDeleted: nowIsDeleted,
      timestamp: DateTime.now().toUtc(),
    ));
  }

  void revertDelete(Subject subject) {
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

  /// `_permanentDelete` must be called from build(), because it doesnt update the state
  /// deletes from cloud and local, other devices must delete it themself
  Future<void> _permanentDelete(List<Subject> subjects) async {
    if (subjects.isEmpty) return;
    for (var element in subjects) {
      subjectsDb.delete(element.id);
    }
    await firebaseService.deleteSubjects(subjects);
  }

  /// `_checkForDeleted` must be called from build(), because it doesnt update the state
  Future<void> _checkForDeleted() async {
    final now = DateTime.now();
    List<Subject> hwsToDelete = [];

    for (var hw in _dbState.values) {
      if (hw.isDeleted && now.difference(hw.timestamp) > Duration(days: 7)) {
        hwsToDelete.add(hw);
      }
    }
    await _permanentDelete(hwsToDelete);
  }

  /// checks and updates/adds subject from firestore
  Future<void> checkFireSubject(Subject fireSubject) async {
    final localSubject = _dbState.values.where(
      (element) {
        return element.id == fireSubject.id;
      },
    ).firstOrNull;

    // if it doesnt exist in local, add it
    if (localSubject == null) {
      // print(
      //     '\u001b[1;92madding from fire: ${fireSubject.name}: ${fireSubject.order}');

      await saveNew(
        fireSubject.convert(),
        overrideId: fireSubject.id,
        addToFire: false,
        addToEnd: false,
      );
      return;
    }

    final localTime = localSubject.timestamp;
    final fireTime = fireSubject.timestamp;

    if (fireTime.millisecondsSinceEpoch > localTime.millisecondsSinceEpoch) {
      // print(
      //     '\u001b[1;93mediting from fire: ${fireSubject.name}: ${fireSubject.order}');

      edit(
        fireSubject,
        syncWithFire: false,
        checkOrder: true,
      );
    } else if (fireTime.millisecondsSinceEpoch <
        localTime.millisecondsSinceEpoch) {
      // print(
      //     '\u001b[1;93mediting from hive: ${fireSubject.name}: ${fireSubject.order}');

      firebaseService.editSubjects([localSubject.copyWith(id: fireSubject.id)]);
    } else {
      // print('same date');
    }
    return;
  }
}
