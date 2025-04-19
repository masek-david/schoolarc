import 'dart:async';
import 'dart:developer';

import 'package:riverpod/riverpod.dart';
import 'package:school_manager/models/exams/exam_id_model.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/exams/exam_entity_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/provider/firebase_activity_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';

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

// key for each day is the utc value, with time being 0:00:00
final examsDatesProvider = Provider<Map<DateTime, List<Exam>>>(
  (ref) {
    final exams = ref.watch(examProvider);

    return examsSortByDate(exams);
  },
);

// key for each day is the local date value, with time being 0:00:00
Map<DateTime, List<Exam>> examsSortByDate(Map<String, Exam> original) {
  Map<DateTime, List<Exam>> examsDateMap = {};

  original.forEach(
    (dbIndex, exam) {
      final examDeadlineLocal = exam.deadline.toLocal();

      DateTime dateNoTime = DateTime(examDeadlineLocal.year,
          examDeadlineLocal.month, examDeadlineLocal.day);

      if (!exam.isDeleted) {
        if (examsDateMap.containsKey(dateNoTime)) {
          // If it exists, add the event to the existing list
          examsDateMap[dateNoTime]!.add(exam);
        } else {
          // If it does not exist, create a new list with the exam
          examsDateMap[dateNoTime] = [exam];
        }
      }
    },
  );

  examsDateMap.forEach((key, value) {
    value.sort((a, b) => a.order.compareTo(b.order));
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
  StreamSubscription<ExamWithID>? listenFirebase;

  @override
  Map<String, Exam> build() {
    // listen to subjectsProvider changes
    ref.listen(subjectsProvider, (_, next) {
      subjects = next;
      _loadState();
    });
    subjects = ref.read(subjectsProvider);

    listenToFirebase();
    _checkForDeleted();

    scheduleMidnightTask();

    return _dbState;
  }

  void _loadState() {
    state = _dbState;
  }

  // returns state saved in database
  Map<String, Exam> get _dbState {
    return examsDb.getDatabase().map(
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

    listenFirebase = firebaseService.listenExams().listen((event) async {
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
          if (value.deadline.isBeforeToday()) {
            updated[key] = value.copyWith(isCompleted: true);
          }
        }
      },
    );

    state = {...state, ...updated};
  }

  /// checks all online and offline
  Future<void> syncAll() async {
    _loadState();
    await listenToFirebase();
    final fireExams = await firebaseService.getAllExams();

    fireExams?.forEach(
      (element) {
        checkFireExam(element);
      },
    );

    await _checkForDeleted();
    _loadState();

    state.forEach(
      (key, value) {
        bool isSynced = fireExams
                ?.where(
                  (element) => element.id == value.id,
                )
                .firstOrNull !=
            null;

        if (!isSynced) {
          edit(value);
        }
      },
    );

    return;
  }

  Future<void> saveNew(
    ExamEntity exam, {
    // if null, new id is generated
    String? overrideId,
    bool addToFire = true,
    // sets the order to put the task to the end
    bool addToEnd = true,
  }) async {
    if (addToEnd) {
      exam = exam.copyWith(
          order: _dbState.values
              .where(
                (element) =>
                    !element.isDeleted &&
                    !element.isCompleted &&
                    element.priority.index == exam.priority,
              )
              .length);
    }

    final id = overrideId ?? uuid.v4();

    final originalState = _dbState;
    await examsDb.addExam(id, exam);

    final Exam? examWithSameOrder = originalState.values
        .where((element) =>
            element.order == exam.order &&
            !element.isDeleted &&
            !element.isCompleted)
        .firstOrNull;

    if (!exam.isDeleted && exam.date.isBeforeToday()) {
      if (examWithSameOrder != null && !addToEnd) {
        if (exam.timestamp.millisecondsSinceEpoch <
            examWithSameOrder.timestamp.millisecondsSinceEpoch) {
          // if the new one is older, add it after the old one
          exam = exam.copyWith(order: exam.order + 1);
          examsDb.editExam(id, exam);
          // if the new one is newer, add it before old
        }
        reorder(
          null,
          exam.order,
          null,
          exam.priority,
          exam.convert(id, subjects[exam.subjectId]),
        );
      }
    }

    state = {...state, id: exam.convert(id, subjects[exam.subjectId])};
    if (addToFire) {
      await firebaseService
          .addExam(exam.convert(id, subjects[exam.subjectId]));
    }

    return;
  }

  /// assign timestamp manually, if no id, it will add it as now
  void edit(Exam editedExam, {bool syncWithFire = true}) async {
    final old = _dbState[editedExam.id]!;

    editedExam = editedExam.copyWith(
      isCompleted: editedExam.deadline.isBeforeToday(),
    );

    // if it wasnt and isnt in the sorted view (if it is and was deleted or is and was completed), dont sort
    if (!((editedExam.isDeleted && old.isDeleted) ||
        (editedExam.isCompleted && old.isCompleted))) {
      // if now is deleted or now is completed (should hide)
      if ((editedExam.isDeleted && !old.isDeleted) ||
          (editedExam.isCompleted && !old.isCompleted)) {
        reorder(
          old.order,
          null,
          old.priority.index,
          null,
          null,
        );
      }
      // if now isnt deleted or now isnt completed (should appear)
      if ((!editedExam.isDeleted && old.isDeleted) ||
          (!editedExam.isCompleted && old.isCompleted)) {
        reorder(
          null,
          editedExam.order,
          null,
          editedExam.priority.index,
          editedExam,
        );
      }

      // if order has been changed
      if (old.order != editedExam.order ||
          old.priority.index != editedExam.priority.index) {
        await reorder(
          old.order,
          editedExam.order,
          old.priority.index,
          editedExam.priority.index,
          null,
        );
      }
    }

    examsDb.editExam(editedExam.id, editedExam.convert());

    if (syncWithFire) {
      firebaseService.editExams([editedExam]);
    }

    state = {...state, editedExam.id: editedExam};
  }

  /// updates all with changed order, if [oldIndex] is null, it will only be added and [exam] cant be null, if [newIndex] is null, it will be only removed
  Future<void> reorder(
    int? oldIndex,
    int? newIndex,
    int? oldPriority,
    int? newPriority,
    Exam? exam, {
    /// timestamp updated only for the moved subject if [addTimestamp] is true, which is only when it is called from eg. the UI
    bool addTimestamp = false,
  }) async {
    if ((oldIndex == null || oldPriority == null) && exam == null) {
      throw '[oldIndex], [oldPriority] and [subject] are all null';
    }

    var oldPriorityList = _dbState.values
        .where(
          (element) =>
              !element.isDeleted &&
              !element.isCompleted &&
              element.priority.index == oldPriority,
        )
        .toList();
    var newPriorityList = _dbState.values
        .where(
          (element) =>
              !element.isDeleted &&
              !element.isCompleted &&
              element.priority.index == newPriority,
        )
        .toList();

    oldPriorityList.sort((a, b) => a.order.compareTo(b.order));
    newPriorityList.sort((a, b) => a.order.compareTo(b.order));

    if (oldIndex != null && oldPriority != null) {
      exam = oldPriorityList.removeAt(oldIndex >= oldPriorityList.length
          ? oldPriorityList.length - 1
          : oldIndex);
      if (oldPriority == newPriority) {
        newPriorityList.removeAt(oldIndex >= newPriorityList.length
            ? newPriorityList.length - 1
            : oldIndex);
      }
    }
    if (addTimestamp) {
      exam = exam!.copyWith(timestamp: DateTime.now().toUtc());
    }
    // now exam cant be null
    if (newIndex != null && newPriority != null) {
      exam = exam!.copyWith(priority: TaskPriority(newPriority));
      newPriorityList.insert(
          newIndex > newPriorityList.length ? newPriorityList.length : newIndex,
          exam);
    }

    final editedExams = <String, Exam>{};

    if (oldPriority != newPriority) {
      for (int i = 0; i < oldPriorityList.length; i++) {
        final edited = oldPriorityList[i].copyWith(order: i);
        final oldExam = _dbState[edited.id];

        if (edited.order != oldExam?.order) {
          editedExams[edited.id] = edited;
        }
      }
    }
    for (int i = 0; i < newPriorityList.length; i++) {
      final edited = newPriorityList[i].copyWith(order: i);
      final oldExam = _dbState[edited.id];

      if (edited.order != oldExam?.order ||
          edited.priority.index != oldExam?.priority.index) {
        editedExams[edited.id] = edited;
      }
    }

    editedExams.forEach(
      (key, value) async {
        examsDb.editExam(key, value.convert());
      },
    );

    firebaseService.editExams(editedExams.values.toList());

    state = {...state, ...editedExams};
    return;
  }

  void convert(Exam exam) {
    delete(exam);
    ref.read(hwProvider.notifier).saveNew(exam.toHw());
  }

  void delete(Exam exam) {
    edit(exam.copyWith(timestamp: DateTime.now().toUtc(), isDeleted: true));
  }

  void revertDelete(Exam exam) {
    edit(
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
    }
    await firebaseService.deleteExams(exams);
  }

  /// `_checkForDeleted` must be called from build(), because it doesnt update the state
  Future<void> _checkForDeleted() async {
    final now = DateTime.now();
    List<Exam> examsToDelete = [];

    for (var exam in _dbState.values) {
      if (exam.isDeleted &&
          now.difference(exam.timestamp) > Duration(days: 7)) {
        examsToDelete.add(exam);
      }
    }
    await _permanentDelete(examsToDelete);
  }

  /// checks and updates/adds exam from firestore, overwrites the newest version
  Future<void> checkFireExam(ExamWithID fireExam) async {
    // print('checking exam from fire: ${fireExam.toString()}');

    final localExam = _dbState.values.where(
      (element) {
        return element.id == fireExam.id;
      },
    ).firstOrNull;

    // if it doesnt exist in local, add it
    if (localExam == null) {
      // print(
      //     '\u001b[1;92madding exam from fire: ${fireExam.toString()}');

      await saveNew(
        fireExam,
        overrideId: fireExam.id,
        addToFire: false,
        addToEnd: false,
      );
      return;
    }

    final localTime = localExam.timestamp;
    final fireTime = fireExam.timestamp;

    if (fireTime.millisecondsSinceEpoch > localTime.millisecondsSinceEpoch) {
      // print(
      //     '\u001b[1;93mediting exam from fire: ${fireExam.toString()}');

      edit(
        fireExam.convert(fireExam.id, subjects[fireExam.subjectId]),
        syncWithFire: false,
      );
    } else if (fireTime.millisecondsSinceEpoch <
        localTime.millisecondsSinceEpoch) {
      // print(
      //     '\u001b[1;93mediting exam from hive: ${fireExam.toString()}');

      firebaseService.editExams([localExam.copyWith(id: fireExam.id)]);
    }
    return;
  }
}
