import 'dart:async';
import 'dart:developer';

import 'package:riverpod/riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exams/exam_entity_id_model.dart';
import 'package:schoolarc/models/exams/exam_entity_model.dart';
import 'package:schoolarc/models/exams/exam_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/provider/firebase/firebase_activity_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/utils/globals.dart';

final examProvider =
    NotifierProvider<ExamNotifier, Map<String, Exam>>(ExamNotifier.new);

// sorts by priorities (0-3), orders them
final examSortedProvider = Provider<Map<int, List<Exam>>>(
  (ref) {
    final exams = ref.watch(examProvider);

    Map<int, List<Exam>> examPriorityMap = {
      0: <Exam>[],
      1: <Exam>[],
      2: <Exam>[],
      3: <Exam>[],
    };

    exams.forEach(
      (key, exam) {
        if (!exam.isDeleted && !exam.isCompleted) {
          examPriorityMap[exam.priority.index]!.add(exam);
        }
      },
    );

    examPriorityMap.forEach(
      (key, value) {
        value.sort(
          (a, b) => a.order.compareTo(b.order),
        );
      },
    );

    return examPriorityMap;
  },
);

final examsDatesProvider = Provider<Map<Date, List<Exam>>>(
  (ref) {
    final exams = ref.watch(examProvider);

    return examsSortByDate(exams);
  },
);

Map<Date, List<Exam>> examsSortByDate(Map<String, Exam> original) {
  Map<Date, List<Exam>> examsDateMap = {};

  original.forEach(
    (dbIndex, exam) {
      final date = exam.date;

      if (!exam.isDeleted) {
        if (examsDateMap.containsKey(date)) {
          // If it exists, add the event to the existing list
          examsDateMap[date]!.add(exam);
        } else {
          // If it does not exist, create a new list with the exam
          examsDateMap[date] = [exam];
        }
      }
    },
  );

  examsDateMap.forEach((key, value) {
    value.sort((a, b) => a.id.compareTo(b.id));
    value.sort((a, b) => b.priority.index.compareTo(a.priority.index));
  });

  return examsDateMap;
}

final examCompletedProvider = Provider<List<Exam>>(
  (ref) {
    final exams = ref.watch(examProvider);

    final list = <Exam>[];

    exams.forEach(
      (key, exam) {
        if (!exam.isDeleted && exam.isCompleted) {
          list.add(exam);
        }
      },
    );

    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return list;
  },
);

final examDeletedProvider = Provider<List<Exam>>(
  (ref) {
    final exams = ref.watch(examProvider);

    final list = exams.values
        .where(
          (element) => element.isDeleted,
        )
        .toList();
    list.sort(
      (a, b) => a.timestamp.compareTo(b.timestamp),
    );

    return list;
  },
);

class ExamNotifier extends Notifier<Map<String, Exam>> {
  Map<String, Subject> subjects = {};
  StreamSubscription<ExamEntityWithID>? listenFirebase;

  @override
  Map<String, Exam> build() {
    // listen to subjectsProvider changes
    ref.listen(subjectsNonDeletedProvider, (_, next) {
      subjects = next;
      _reloadState();
    });
    subjects = ref.read(subjectsNonDeletedProvider);

    listenToFirebase();
    Future.microtask(() => _checkForDeleted());

    scheduleMidnightTask();

    return _dbState;
  }

  void _reloadState() {
    state = _dbState;
  }

  // returns state saved in database
  Map<String, Exam> get _dbState {
    return examsDb.readDatabase().map(
      (key, value) {
        return MapEntry(
          key,
          value.convert(key, subjects[value.subjectId]),
        );
      },
    );
  }

  Future<void> listenToFirebase() async {
    await listenFirebase?.cancel();

    listenFirebase =
        ref.read(firebaseServiceProvider).listenExams().listen((event) async {
      ref.read(firebaseActivityProvider.notifier).read(2);

      await checkFireExam(event);
    }, onError: (error) {
      log('error listening to firebase exams: ${error.toString()}');
    });
  }

  /// at midnight update state with exams for yesterday being completed
  void scheduleMidnightTask() {
    DateTime now = DateTime.now();
    DateTime nextMidnight = DateTime(now.year, now.month, now.day + 1, 0, 0, 0);

    Duration initialDelay = nextMidnight.difference(now);

    Future.delayed(initialDelay, () {
      checkAllIfCompleted();
      Timer.periodic(const Duration(days: 1), (timer) {
        checkAllIfCompleted();
      });
    });
  }

  void checkAllIfCompleted() {
    Map<String, Exam> updated = {};

    state.forEach(
      (key, value) {
        if (!value.isCompleted && !value.isDeleted) {
          if (value.date.isBefore(Date.today())) {
            updated[key] = value.copyWith(isCompleted: true);
          }
        }
      },
    );

    state = {...state, ...updated};
  }

  /// checks all online and offline
  Future<void> syncAll() async {
    await listenToFirebase();
    final fireExams = await ref.read(firebaseServiceProvider).getAllExams();

    fireExams?.forEach(
      (element) {
        checkFireExam(element);
      },
    );

    state.forEach(
      (key, value) {
        bool isSynced = fireExams
                ?.where(
                  (element) => element.id == value.id,
                )
                .firstOrNull !=
            null;

        if (!isSynced) {
          update(value);
        }
      },
    );
  }

  /// If [addToEnd] is true, order will be set to end of the list of its priority
  Future<void> create(
    ExamEntity exam, {
    String? overrideId,
    bool syncWithFire = true,
    bool addToEnd = true,
  }) async {
    if (addToEnd) {
      exam = exam.copyWith(
        order: _getOrder(
          index: null,
          priority: exam.priority,
          id: null,
        ),
      );
    }

    final id = overrideId ?? uuid.v4();
    await examsDb.put(id, exam);

    state = {...state, id: exam.convert(id, subjects[exam.subjectId])};

    if (syncWithFire) {
      await ref.read(firebaseServiceProvider).createExam(
            exam.convert(id, subjects[exam.subjectId]),
          );
    }

    return;
  }

  /// You have to assign timestamp manually, if no id, it will add it as now
  ///
  /// [checkOrder] is false when calling from reorder, because its not neccesary to check again
  Future<void> update(
    Exam edited, {
    bool syncWithFire = true,
    bool checkOrder = true,
  }) async {
    edited = edited.copyWith(
      isCompleted: edited.date.isBefore(Date.today()),
    );

    final old = state[edited.id]!;
    if (old.priority.index != edited.priority.index &&
        !edited.isCompleted &&
        !edited.isDeleted &&
        checkOrder) {
      edited = edited.copyWith(
        order: _getOrder(
          index: null,
          priority: edited.priority.index,
          id: edited.id,
        ),
      );
    }

    examsDb.put(edited.id, edited.convert());
    if (syncWithFire) {
      ref.read(firebaseServiceProvider).updateExams([edited]);
    }

    state = {...state, edited.id: edited};
  }

  /// [newIndex] and [newPriority] are where the item will be placed
  ///
  /// timestamp updated automatically for the moved subject
  Future<void> reorder(
    final Exam original,
    int newIndex,
    int newPriority,
  ) async {
    await update(
      original.copyWith(
        timestamp: DateTime.now(),
        priority: TaskPriority(newPriority),
        order: _getOrder(
          index: newIndex,
          priority: newPriority,
          id: original.id,
        ),
      ),
      checkOrder: false,
    );
  }

  /// If [index] is null, insert at end. If [index] is 0, insert at begining
  ///
  /// [id] has to be provided, unless the task doesn't exist
  double _getOrder({
    required int? index,
    required int priority,
    required String? id,
  }) {
    final list = state.values
        .where(
          (element) =>
              !element.isDeleted &&
              !element.isCompleted &&
              element.priority.index == priority &&
              element.id != id,
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

  /// deletes this exam and creates new homework
  void convert(Exam exam) {
    _permanentDelete([exam]);
    ref.read(hwProvider.notifier).create(exam.toHwEntity());
  }

  void delete(Exam exam) {
    update(exam.copyWith(timestamp: DateTime.now().toUtc(), isDeleted: true));
  }

  void revertDelete(Exam exam) {
    update(
      exam.copyWith(
          timestamp: DateTime.now().toUtc(),
          isDeleted: false,
          stateReaddingVersion: exam.stateReaddingVersion + 1),
    );
  }

  /// `_permanentDelete` must be called from build(), because it doesnt update the state
  Future<void> _permanentDelete(List<Exam> exams) async {
    if (exams.isEmpty) return;
    for (var element in exams) {
      examsDb.delete(element.id);
      state.remove(element.id);
    }

    state = {...state};
    await ref.read(firebaseServiceProvider).deleteExams(exams);
  }

  Future<void> _checkForDeleted() async {
    final now = DateTime.now();
    List<Exam> examsToDelete = [];

    for (var exam in state.values) {
      if (exam.isDeleted &&
          now.difference(exam.timestamp) > const Duration(days: 7)) {
        examsToDelete.add(exam);
      }
    }
    await _permanentDelete(examsToDelete);
  }

  /// checks and updates/adds exam from firestore, overwrites the newest version
  Future<void> checkFireExam(ExamEntityWithID fireExam) async {
    // print('checking exam from fire: ${fireExam.toString()}');

    final localExam = state.values.where(
      (element) {
        return element.id == fireExam.id;
      },
    ).firstOrNull;

    // if it doesnt exist in local, add it
    if (localExam == null) {
      // print(
      //     '\u001b[1;92madding exam from fire: ${fireExam.toString()}');

      await create(
        fireExam,
        overrideId: fireExam.id,
        syncWithFire: false,
        addToEnd: false,
      );
      return;
    }

    final localTime = localExam.timestamp;
    final fireTime = fireExam.timestamp;

    if (fireTime.millisecondsSinceEpoch > localTime.millisecondsSinceEpoch) {
      // print(
      //     '\u001b[1;93mediting exam from fire: ${fireExam.toString()}');

      update(
        fireExam.convert(fireExam.id, subjects[fireExam.subjectId]),
        syncWithFire: false,
      );
    } else if (fireTime.millisecondsSinceEpoch <
        localTime.millisecondsSinceEpoch) {
      // print(
      //     '\u001b[1;93mediting exam from hive: ${fireExam.toString()}');

      ref
          .read(firebaseServiceProvider)
          .updateExams([localExam.copyWith(id: fireExam.id)]);
    }
    return;
  }
}
