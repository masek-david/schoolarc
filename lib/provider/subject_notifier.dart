import 'dart:async';
import 'dart:developer';

import 'package:riverpod/riverpod.dart';
import 'package:schoolarc/models/subjects/subject_entity_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/firebase/firebase_activity_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/utils/globals.dart';

final subjectsProvider =
    NotifierProvider<SubjectNotifier, Map<String, Subject>>(
        SubjectNotifier.new);

final subjectsSortedProvider = Provider<List<Subject>>((ref) {
  final subjects = ref.watch(subjectsProvider);

  // Filter out deleted subjects and sort based on the `order` field.
  return subjects.values.where((subject) => !subject.isDeleted).toList()
    ..sort((a, b) => (a.order).compareTo(b.order));
});

final subjectsNonDeletedProvider = Provider<Map<String, Subject>>((ref) {
  final subjects = Map<String, Subject>.from(ref.watch(subjectsProvider));
  subjects.removeWhere((key, value) => value.isDeleted);
  return subjects;
});

final subjectsUsedTimesProvider = Provider<Map<String, int>>((ref) {
  final Map<String, int> map = {};
  final exams = ref.watch(examProvider);
  final hws = ref.watch(hwProvider);

  exams.forEach(
    (key, value) {
      final subjectId = value.subject?.id;

      if (subjectId != null) {
        map[subjectId] = (map[subjectId] ?? 0) + 1;
      }
    },
  );
  hws.forEach(
    (key, value) {
      final subjectId = value.subject?.id;

      if (subjectId != null) {
        map[subjectId] = (map[subjectId] ?? 0) + 1;
      }
    },
  );

  return map;
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
    Future.microtask(() => _checkForDeleted());

    return _dbState;
  }

  Map<String, Subject> get _dbState {
    return subjectsDb.readDatabase();
  }

  Future<void> listenToFirebase() async {
    await listenFirebase?.cancel();

    listenFirebase = ref.read(firebaseServiceProvider).listenSubjects().listen(
        (event) async {
      ref.read(firebaseActivityProvider.notifier).read(0);

      await checkFireSubject(event);
    }, onError: (error) {
      log('error listening to firebase subjects: ${error.toString()}');
    });
  }

  Future<void> syncAll() async {
    await listenToFirebase();
    final fireSubjects = await ref.read(firebaseServiceProvider).getSubjects();

    fireSubjects?.forEach(
      (element) async {
        await checkFireSubject(element);
      },
    );

    state.forEach((id, subject) {
      final fireSubject = fireSubjects
          ?.where((element) => element.id == subject.id)
          .firstOrNull;
      bool needsSync = fireSubject == null ||
          fireSubject.timestamp.isBefore(subject.timestamp);

      if (needsSync) {
        update(subject);
      }
    });
  }

  /// If [addToEnd] is true, order will be set to end of the list of its priority
  Future<Subject> create(
    SubjectEntity subject, {
    String? overrideId,
    bool syncWithFire = true,
    bool addToEnd = true,
  }) async {
    if (addToEnd) {
      subject = subject.copyWith(
        order: _getOrder(index: null, id: null),
      );
    }

    final id = overrideId ?? uuid.v4();
    await subjectsDb.put(id, subject);

    state = {...state, id: subject.convert(id)};

    if (syncWithFire) {
      await ref.read(firebaseServiceProvider).createSubject(
            subject.convert(id),
          );
    }

    return subject.convert(id);
  }

  /// You have to assign timestamp manually, if no id, it will add it as now
  ///
  /// [checkOrder] is false when calling from reorder, because its not neccesary to check again
  Future<void> update(
    Subject edited, {
    bool syncWithFire = true,
    bool checkOrder = true,
  }) async {
    if (!edited.isDeleted && checkOrder) {
      edited = edited.copyWith(
        order: _getOrder(
          index: null,
          id: edited.id,
        ),
      );
    }

    subjectsDb.put(edited.id, edited.convert());
    state = {...state, edited.id: edited};

    if (syncWithFire) {
      ref.read(firebaseServiceProvider).updateSubjects([edited]);
    }
  }

  /// [newIndex] and [newPriority] are where the item will be placed
  ///
  /// timestamp updated automatically for the moved subject
  Future<void> reorder(final Subject original, int newIndex) async {
    await update(
      original.copyWith(
        timestamp: DateTime.now(),
        order: _getOrder(
          index: newIndex,
          id: original.id,
        ),
      ),
      checkOrder: false,
    );
  }

  /// If [index] is null, insert at end. If [index] is 0, insert at begining
  ///
  /// [id] has to be provided, unless the task doesn't exist
  double _getOrder({required int? index, required String? id}) {
    final list = state.values
        .where(
          (element) => !element.isDeleted && element.id != id,
        )
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));

    final double order;
    final isLast = index == null ? true : index >= list.length;

    if (isLast) {
      order = (list.lastOrNull?.order.ceilToDouble() ?? 0) + 1;
    } else {
      final indexBefore =
          index == 0 ? 0.0 : list.elementAtOrNull(index - 1)?.order ?? 0;
      final indexAfter = list.elementAtOrNull(index)?.order ??
          list.lastOrNull?.order.ceilToDouble() ??
          0 + 1;

      order = getMiddleIndex(indexBefore, indexAfter);
    }
    return order;
  }

  void delete(Subject subject, {bool nowIsDeleted = true}) {
    update(subject.copyWith(
      isDeleted: nowIsDeleted,
      timestamp: DateTime.now().toUtc(),
    ));
  }

  void revertDelete(Subject subject) {
    delete(subject, nowIsDeleted: false);
  }

  Future<void> _permanentDelete(List<Subject> subjects) async {
    if (subjects.isEmpty) return;
    for (var element in subjects) {
      subjectsDb.delete(element.id);
      state.remove(element.id);
    }

    state = {...state};
    await ref.read(firebaseServiceProvider).deleteSubjects(subjects);
  }

  Future<void> _checkForDeleted() async {
    final now = DateTime.now();
    List<Subject> hwsToDelete = [];

    for (var hw in state.values) {
      if (hw.isDeleted &&
          now.difference(hw.timestamp) > const Duration(days: 7)) {
        hwsToDelete.add(hw);
      }
    }
    await _permanentDelete(hwsToDelete);
  }

  /// checks and updates/adds subject from firebase
  Future<void> checkFireSubject(Subject fireSubject) async {
    final localSubject = _dbState.values.where(
      (element) {
        return element.id == fireSubject.id;
      },
    ).firstOrNull;

    // print('\u001b[1;92m checking from fire: ${fireSubject.toString()}');

    // if it doesnt exist in local, add it5
    if (localSubject == null) {
      // print(
      //     '\u001b[1;92madding from fire: ${fireSubject.name}: ${fireSubject.order}');

      await create(
        fireSubject.convert(),
        overrideId: fireSubject.id,
        syncWithFire: false,
        addToEnd: false,
      );
      return;
    }

    final localTime = localSubject.timestamp;
    final fireTime = fireSubject.timestamp;

    if (fireTime.millisecondsSinceEpoch > localTime.millisecondsSinceEpoch) {
      // print(
      //     '\u001b[1;93mediting from fire: ${fireSubject.name}: ${fireSubject.order}');

      update(
        fireSubject,
        syncWithFire: false,
        checkOrder: true,
      );
    } else if (fireTime.millisecondsSinceEpoch <
        localTime.millisecondsSinceEpoch) {
      // print(
      //     '\u001b[1;93mediting from hive: ${fireSubject.name}: ${fireSubject.order}');

      ref
          .read(firebaseServiceProvider)
          .updateSubjects([localSubject.copyWith(id: fireSubject.id)]);
    } else {
      // print('same date');
    }
    return;
  }
}
