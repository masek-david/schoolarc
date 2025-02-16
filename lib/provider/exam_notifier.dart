import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import 'package:school_manager/models/exams/exam_dto_model.dart';
import 'package:school_manager/models/exams/exam_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/services/exams/exam_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';

final examProvider =
    StateNotifierProvider<ExamNotifier, Map<int, ExamDTO>>((ref) {
  final subjects = ref.watch(subjectsProvider);

  return ExamNotifier(ExamDatabase(), subjects);
});

final examSortedProvider = Provider<Map<int, List<ExamDTO>>>(
  (ref) {
    final exams = ref.watch(examProvider);

    Map<int, List<ExamDTO>> examPriorityMap = {
      0: <ExamDTO>[],
      1: <ExamDTO>[],
      2: <ExamDTO>[],
      3: <ExamDTO>[],
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

final examsDatesProvider = Provider<Map<DateTime, List<ExamDTO>>>(
  (ref) {
    final exams = ref.watch(examProvider);

    Map<DateTime, List<ExamDTO>> examsDateMap = {};

    exams.forEach(
      (dbIndex, exam) {
        final examDeadlineUtc = exam.deadline;

        DateTime dateNoTime = DateTime.utc(
            examDeadlineUtc.year, examDeadlineUtc.month, examDeadlineUtc.day);

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
      value.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    });

    return examsDateMap;
  },
);

final examCompletedProvider = Provider<List<ExamDTO>>(
  (ref) {
    final exams = ref.watch(examProvider);

    final list = <ExamDTO>[];

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

class ExamNotifier extends StateNotifier<Map<int, ExamDTO>> {
  final ExamDatabase _db;
  Map<int, SubjectDTO> subjects;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? listen;

  ExamNotifier(this._db, this.subjects)
      : super(_db.getDatabase().map(
          (key, value) {
            return MapEntry(
                key, value.convertToDTO(key, subjects[value.subjectDbIndex]));
          },
        )) {
    listenToFirebase();
  }

  Map<int, ExamDTO> get _dbState {
    return _db.getDatabase().map(
      (key, value) {
        return MapEntry(
            key, value.convertToDTO(key, subjects[value.subjectDbIndex]));
      },
    );
  }

  Future<void> listenToFirebase() async {
    await listen?.cancel();

    listen = firestoreService.examsListenToChanges().listen((event) async {
      Map<String, Exam> updatedExams = {};

      for (var change in event.docChanges) {
        final doc = change.doc;
        final fireExam = Exam(
          isDeleted: doc['isDeleted'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          fireId: doc.id,
          subjectDbIndex: subjects.values
              .where(
                (exam) => exam.fireId == doc['subjectId'],
              )
              .firstOrNull
              ?.dbIndex,
          text: doc['text'],
          date: (doc['deadline'] as Timestamp).toDate(),
          priority: doc['priority'],
          description: doc['description'],
          order: doc['order'],
        );

        updatedExams[doc.id] = fireExam;
      }

      updatedExams.forEach(
        (key, value) async {
          if (mounted) {
            await checkFireExam(value);
          }
        },
      );
    }, onError: (error) {
      log('error listening to firebase exams: ${error.toString()}');
    });
  }

  void checkAllIfCompleted() {
    Map<int, ExamDTO> updated = {};

    state.forEach(
      (key, value) {
        if (!value.isCompleted) {
          if (value.deadline.isBeforeToday()) {
            updated[key] = value.copyWith(isCompleted: true);
          }
        }
      },
    );

    if (mounted) {
      state = {...state, ...updated};
    }
  }

  Future<void> syncAll() async {
    await listenToFirebase();
    final fireExams = await firestoreService.getAllExams();

    fireExams?.forEach(
      (element) {
        checkFireExam(element);
      },
    );

    state.forEach(
      (key, value) {
        if (value.fireId == null) {
          edit(value);
        } else {
          bool isSynced = fireExams
                  ?.where(
                    (element) => element.fireId == value.fireId,
                  )
                  .firstOrNull !=
              null;

          if (!isSynced) {
            edit(value);
          }
        }
      },
    );

    return;
  }

  Future<void> saveNew(
    Exam exam, {
    bool addToFire = true,
    bool addToEnd = true,
  }) async {
    if (addToEnd) {
      exam.order = _dbState.values
          .where(
            (element) =>
                !element.isDeleted &&
                !element.isCompleted &&
                element.priority.index == exam.priority,
          )
          .length;
    }

    if (addToFire) {
      exam = exam.copyWith(fireId: uuid.v4());
    }

    int dbIndex = await _db.addExam(exam);

    final ExamDTO? examWithSameOrder = mounted
        ? _dbState.values
            .where(
                (element) => element.order == exam.order && !element.isDeleted)
            .firstOrNull
        : null;
    if (examWithSameOrder != null && !addToEnd) {
      if (exam.timestamp.millisecondsSinceEpoch <
          examWithSameOrder.timestamp.millisecondsSinceEpoch) {
        // if the new one is older, add it after the old one
        exam.order++;
        _db.editExam(dbIndex, exam);
        // if the new one is newer, add it before old
      }
      reorder(
        null,
        exam.order,
        null,
        exam.priority,
        exam.convertToDTO(dbIndex, subjects[exam.subjectDbIndex]),
      );
    }

    if (mounted) {
      state = {
        ...state,
        dbIndex: exam.convertToDTO(dbIndex, subjects[exam.subjectDbIndex])
      };
    }
    if (addToFire) {
      await firestoreService
          .addExam(exam.convertToDTO(0, subjects[exam.subjectDbIndex]));
    }

    return;
  }

  /// assign timestamp manually, if no fireId, it will add it
  void edit(
    ExamDTO editedExam, {
    bool syncWithFire = true,
    bool reorderAddTimestamp = true,

    /// [checkOrder] false only when editing from [reorder()]
    bool checkOrder = true,
  }) async {
    final old = _dbState[editedExam.dbIndex]!;

    editedExam = editedExam.copyWith(
      isCompleted: editedExam.deadline.isBeforeToday(),
    );

    if (checkOrder) {
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
    }

    _db.editExam(editedExam.dbIndex, editedExam.convert());

    if (syncWithFire) {
      if (editedExam.fireId == null) {
        editedExam = editedExam.copyWith(fireId: uuid.v4());

        _db.editExam(editedExam.dbIndex, editedExam.convert());
      }
      firestoreService.editExams([editedExam]);
    }

    if (mounted) {
      state = {...state, editedExam.dbIndex: editedExam};
    }
  }

  /// updates all with changed order, if [oldIndex] is null, it will only be added and [exam] cant be null, if [newIndex] is null, it will be only removed
  Future<void> reorder(
    int? oldIndex,
    int? newIndex,
    int? oldPriority,
    int? newPriority,
    ExamDTO? exam, {
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
      exam = exam!.copyWith(timestamp: Timestamp.now());
    }
    // now exam cant be null
    if (newIndex != null && newPriority != null) {
      exam = exam!.copyWith(priority: TaskPriority(newPriority));
      newPriorityList.insert(
          newIndex > newPriorityList.length ? newPriorityList.length : newIndex,
          exam);
    }

    final editedExams = <int, ExamDTO>{};

    if (oldPriority != newPriority) {
      for (int i = 0; i < oldPriorityList.length; i++) {
        final edited = oldPriorityList[i].copyWith(order: i);
        final oldExam = _dbState[edited.dbIndex];

        if (edited.order != oldExam?.order) {
          editedExams[edited.dbIndex] = edited;
        }
      }
    }
    for (int i = 0; i < newPriorityList.length; i++) {
      final edited = newPriorityList[i].copyWith(order: i);
      final oldExam = _dbState[edited.dbIndex];

      if (edited.order != oldExam?.order ||
          edited.priority.index != oldExam?.priority.index) {
        editedExams[edited.dbIndex] = edited;
      }
    }

    editedExams.forEach(
      (key, value) async {
        _db.editExam(value.dbIndex, value.convert());
      },
    );

    firestoreService.editExams(editedExams.values
        .where(
          (element) => element.fireId != null,
        )
        .toList());

    if (mounted) {
      state = {...state, ...editedExams};
    }
    return;
  }

  void delete(ExamDTO exam) {
    edit(exam.copyWith(timestamp: Timestamp.now(), isDeleted: true));
  }

  void revertDelete(ExamDTO exam) {
    edit(exam.copyWith(timestamp: Timestamp.now(), isDeleted: false));
  }

  /// checks and updates/adds exam from firestore
  Future<void> checkFireExam(Exam fireExam) async {
    print('checking exam from fire: ${fireExam.toString()}');

    final localExam = _dbState.values.where(
      (element) {
        return element.fireId == fireExam.fireId;
      },
    ).firstOrNull;

    // if it doesnt exist in local, add it
    if (localExam == null) {
      print(
          '\u001b[1;92madding exam from fire: ${fireExam.text}: ${fireExam.order}');

      await saveNew(
        fireExam,
        addToFire: false,
        addToEnd: false,
      );
      return;
    }

    final localTime = localExam.timestamp.toDate();
    final fireTime = fireExam.timestamp;

    if (fireTime.millisecondsSinceEpoch > localTime.millisecondsSinceEpoch) {
      print(
          '\u001b[1;93mediting exam from fire: ${fireExam.text}: ${fireExam.order}');

      edit(
        fireExam.convertToDTO(
            localExam.dbIndex, subjects[fireExam.subjectDbIndex]),
        syncWithFire: false,
        checkOrder: true,
      );
    } else if (fireTime.millisecondsSinceEpoch <
        localTime.millisecondsSinceEpoch) {
      print(
          '\u001b[1;93mediting exam from hive: ${fireExam.text}: ${fireExam.order}');

      firestoreService.editExams([localExam.copyWith(fireId: fireExam.fireId)]);
    }
    return;
  }
}
