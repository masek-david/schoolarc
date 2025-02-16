import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod/riverpod.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/services/homeworks/hw_database.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';

final hwProvider =
    StateNotifierProvider<HwNotifier, Map<int, HomeworkDTO>>((ref) {
  final subjects = ref.watch(subjectsProvider);

  return HwNotifier(HomeworksDatabase(), subjects);
});

final hwSortedProvider = Provider<Map<int, List<HomeworkDTO>>>(
  (ref) {
    final hws = ref.watch(hwProvider);

    Map<int, List<HomeworkDTO>> hwPriorityMap = {
      0: <HomeworkDTO>[],
      1: <HomeworkDTO>[],
      2: <HomeworkDTO>[],
      3: <HomeworkDTO>[],
    };

    hws.forEach(
      (key, hw) {
        if (hw.isBeingAnimated || (!hw.isDeleted && !hw.isCompleted)) {
          hwPriorityMap[hw.priority.index]!.add(hw);
        }
      },
    );

    hwPriorityMap.forEach(
      (key, value) {
        value.sort(
          (a, b) => a.order.compareTo(b.order),
        );
      },
    );

    return hwPriorityMap;
  },
);

final hwDatesProvider = Provider<Map<DateTime, List<HomeworkDTO>>>(
  (ref) {
    final hws = ref.watch(hwProvider);

    Map<DateTime, List<HomeworkDTO>> hwDateMap = {};

    hws.forEach(
      (dbIndex, homework) {
        final hwDeadlineUtc = homework.deadline;

        DateTime dateNoTime = DateTime.utc(
            hwDeadlineUtc.year, hwDeadlineUtc.month, hwDeadlineUtc.day);

        if (!homework.isDeleted) {
          if (hwDateMap.containsKey(dateNoTime)) {
            // If it exists, add the event to the existing list
            hwDateMap[dateNoTime]!.add(homework);
          } else {
            // If it does not exist, create a new list with the exam
            hwDateMap[dateNoTime] = [homework];
          }
        }
      },
    );

    hwDateMap.forEach((key, value) {
      value.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    });

    return hwDateMap;
  },
);

final hwCompletedProvider = Provider<List<HomeworkDTO>>(
  (ref) {
    final hws = ref.watch(hwProvider);

    final list = <HomeworkDTO>[];

    hws.forEach(
      (key, hw) {
        if (!hw.isDeleted && hw.isCompleted && !hw.isBeingAnimated) {
          list.add(hw);
        }
      },
    );

    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return list;
  },
);

final hwMissedProvider = Provider<List<HomeworkDTO>>(
  (ref) {
    final hws = ref.watch(hwProvider);

    List<HomeworkDTO> missedHw = [];

    hws.forEach(
      (dbIndex, hw) {
        if (hw.deadline.isBeforeToday() &&
            !hw.isDeleted &&
            (!hw.isCompleted || hw.isBeingAnimated)) {
          missedHw.add(hw);
        }
      },
    );

    missedHw.sort((a, b) => a.deadline.compareTo(b.deadline));
    return missedHw;
  },
);

class HwNotifier extends StateNotifier<Map<int, HomeworkDTO>> {
  final HomeworksDatabase _db;
  Map<int, SubjectDTO> subjects;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? listen;

  HwNotifier(this._db, this.subjects)
      : super(_db.getDatabase().map(
          (key, value) {
            return MapEntry(
                key, value.convertToDTO(key, subjects[value.subjectDbIndex]));
          },
        )) {
    listenToFirebase();
  }

  Map<int, HomeworkDTO> get _dbState {
    return _db.getDatabase().map(
      (key, value) {
        return MapEntry(
            key, value.convertToDTO(key, subjects[value.subjectDbIndex]));
      },
    );
  }

  Future<void> listenToFirebase() async {
    await listen?.cancel();

    listen = firestoreService.homeworksListenToChanges().listen((event) async {
      Map<String, Homework> updatedHws = {};

      for (var change in event.docChanges) {
        final doc = change.doc;
        final fireHw = Homework(
          isDeleted: doc['isDeleted'],
          timestamp: (doc['timestamp'] as Timestamp).toDate(),
          fireId: doc.id,
          subjectDbIndex: subjects.values
              .where(
                (homework) => homework.fireId == doc['subjectId'],
              )
              .firstOrNull
              ?.dbIndex,
          text: doc['text'],
          deadline: (doc['deadline'] as Timestamp).toDate(),
          isCompleted: doc['isCompleted'],
          priority: doc['priority'],
          description: doc['description'],
          order: doc['order'],
        );

        updatedHws[doc.id] = fireHw;
      }

      updatedHws.forEach(
        (key, value) async {
          await checkFireHomework(value);
        },
      );
    }, onError: (error) {
      log('error listening to firebase hws: ${error.toString()}');
    });
  }

  Future<void> syncAll() async {
    await listenToFirebase();
    final fireHws = await firestoreService.getAllHomeworks();

    fireHws?.forEach(
      (element) {
        checkFireHomework(element);
      },
    );

    state.forEach(
      (key, value) {
        if (value.fireId == null) {
          edit(value);
        } else {
          bool isSynced = fireHws
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
    Homework hw, {
    bool addToFire = true,
    bool addToEnd = true,
  }) async {
    if (addToEnd) {
      hw.order = _dbState.values
          .where(
            (element) =>
                !element.isDeleted &&
                !element.isCompleted &&
                element.priority.index == hw.priority,
          )
          .length;
    }

    if (addToFire) {
      hw = hw.copyWith(fireId: uuid.v4());
    }

    int dbIndex = await _db.addHw(hw);

    final HomeworkDTO? hwWithSameOrder = _dbState.values
        .where((element) => element.order == hw.order && !element.isDeleted)
        .firstOrNull;
    if (hwWithSameOrder != null && !addToEnd) {
      if (hw.timestamp.millisecondsSinceEpoch <
          hwWithSameOrder.timestamp.millisecondsSinceEpoch) {
        // if the new one is older, add it after the old one
        hw.order++;
        _db.editHw(dbIndex, hw);
        // if the new one is newer, add it before old
      }
      reorder(
        null,
        hw.order,
        null,
        hw.priority,
        hw.convertToDTO(dbIndex, subjects[hw.subjectDbIndex]),
      );
    }

    if (mounted) {
      state = {
        ...state,
        dbIndex: hw.convertToDTO(dbIndex, subjects[hw.subjectDbIndex])
      };
    }

    if (addToFire) {
      await firestoreService
          .addHomework(hw.convertToDTO(0, subjects[hw.subjectDbIndex]));
    }

    return;
  }

  /// assign timestamp manually, if no fireId, it will add it
  void edit(
    HomeworkDTO editedHw, {
    bool syncWithFire = true,
    bool reorderAddTimestamp = true,

    /// [checkOrder] false only when editing from [reorder()]
    bool checkOrder = true,

    /// to delay updating state to let animation play, only to complete a hw
    bool stateUpdateDelay = false,
  }) async {
    final old = _dbState[editedHw.dbIndex]!;

    if (checkOrder && !stateUpdateDelay) {
      // if it wasnt and isnt in the sorted view (if it is and was deleted or is and was completed), dont sort
      if (!((editedHw.isDeleted && old.isDeleted) ||
          (editedHw.isCompleted && old.isCompleted))) {
        // if now is deleted or now is completed (should hide)
        if ((editedHw.isDeleted && !old.isDeleted) ||
            (editedHw.isCompleted && !old.isCompleted)) {
          reorder(
            old.order,
            null,
            old.priority.index,
            null,
            null,
          );
        }
        // if now isnt deleted or now isnt completed (should appear)
        if ((!editedHw.isDeleted && old.isDeleted) ||
            (!editedHw.isCompleted && old.isCompleted)) {
          reorder(
            null,
            editedHw.order,
            null,
            editedHw.priority.index,
            editedHw,
          );
        }

        // if order has been changed
        if (old.order != editedHw.order ||
            old.priority.index != editedHw.priority.index) {
          await reorder(
            old.order,
            editedHw.order,
            old.priority.index,
            editedHw.priority.index,
            null,
          );
        }
      }
    }

    _db.editHw(editedHw.dbIndex, editedHw.convert());

    if (syncWithFire) {
      if (editedHw.fireId == null) {
        editedHw = editedHw.copyWith(fireId: uuid.v4());

        _db.editHw(editedHw.dbIndex, editedHw.convert());
      }
      firestoreService.editHomeworks([editedHw]);
    }

    if (stateUpdateDelay && mounted) {
      state = {
        ...state,
        editedHw.dbIndex: editedHw.copyWith(isBeingAnimated: true),
      };

      await Future.delayed(Duration(seconds: 1));
      if (mounted) {
        state = {
          ...state,
          editedHw.dbIndex:
              state[editedHw.dbIndex]!.copyWith(isBeingAnimated: false),
        };
      }
    } else if (mounted) {
      state = {
        ...state,
        editedHw.dbIndex: editedHw.copyWith(isBeingAnimated: false)
      };
    }
  }

  /// updates all with changed order, if [oldIndex] is null, it will only be added and [homework] cant be null, if [newIndex] is null, it will be only removed
  Future<void> reorder(
    int? oldIndex,
    int? newIndex,
    int? oldPriority,
    int? newPriority,
    HomeworkDTO? homework, {
    /// timestamp updated only for the moved subject if [addTimestamp] is true, which is only when it is called from eg. the UI
    bool addTimestamp = false,
  }) async {
    if ((oldIndex == null || oldPriority == null) && homework == null) {
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
      homework = oldPriorityList.removeAt(oldIndex >= oldPriorityList.length
          ? oldPriorityList.length - 1
          : oldIndex);
      if (oldPriority == newPriority) {
        newPriorityList.removeAt(oldIndex >= newPriorityList.length
            ? newPriorityList.length - 1
            : oldIndex);
      }
    }
    if (addTimestamp) {
      // now the timestamp is
      homework = homework!.copyWith(timestamp: Timestamp.now());
    }
    // now homework cant be null
    if (newIndex != null && newPriority != null) {
      homework = homework!.copyWith(priority: TaskPriority(newPriority));
      newPriorityList.insert(
          newIndex > newPriorityList.length ? newPriorityList.length : newIndex,
          homework);
    }

    final editedHomeworks = <int, HomeworkDTO>{};

    if (oldPriority != newPriority) {
      for (int i = 0; i < oldPriorityList.length; i++) {
        final edited = oldPriorityList[i].copyWith(order: i);
        final oldHw = _dbState[edited.dbIndex];

        if (edited.order != oldHw?.order) {
          editedHomeworks[edited.dbIndex] = edited;
        }
      }
    }
    for (int i = 0; i < newPriorityList.length; i++) {
      final edited = newPriorityList[i].copyWith(order: i);
      final oldHw = _dbState[edited.dbIndex];

      if (edited.order != oldHw?.order ||
          edited.priority.index != oldHw?.priority.index) {
        editedHomeworks[edited.dbIndex] = edited;
      }
    }

    editedHomeworks.forEach(
      (key, value) async {
        _db.editHw(value.dbIndex, value.convert());
      },
    );

    firestoreService.editHomeworks(editedHomeworks.values
        .where(
          (element) => element.fireId != null,
        )
        .toList());

    if (mounted) {
      state = {...state, ...editedHomeworks};
    }
    return;
  }

  void complete(HomeworkDTO hw, bool nowIsCompleted) {
    edit(
      hw.copyWith(timestamp: Timestamp.now(), isCompleted: nowIsCompleted),
      stateUpdateDelay: nowIsCompleted,
    );
  }

  void delete(HomeworkDTO hw) {
    edit(hw.copyWith(timestamp: Timestamp.now(), isDeleted: true));
  }

  void revertDelete(HomeworkDTO hw) {
    edit(hw.copyWith(timestamp: Timestamp.now(), isDeleted: false));
  }

  /// checks and updates/adds hw from firestore
  Future<void> checkFireHomework(Homework fireHw) async {
    print('checking hw from fire: ${fireHw.toString()}');
    
    final localHw = _dbState.values.where(
      (element) {
        return element.fireId == fireHw.fireId;
      },
    ).firstOrNull;

    // if it doesnt exist in local, add it
    if (localHw == null) {
      print('\u001b[1;92madding hw from fire: ${fireHw.toString()}');

      await saveNew(
        fireHw,
        addToFire: false,
        addToEnd: false,
      );
      return;
    }

    final localTime = localHw.timestamp.toDate();
    final fireTime = fireHw.timestamp;

    if (fireTime.millisecondsSinceEpoch > localTime.millisecondsSinceEpoch) {
      print('\u001b[1;93mediting hw from fire: ${fireHw.toString()}');

      edit(
        fireHw.convertToDTO(localHw.dbIndex, subjects[fireHw.subjectDbIndex]),
        syncWithFire: false,
        checkOrder: true,
      );
    } else if (fireTime.millisecondsSinceEpoch <
        localTime.millisecondsSinceEpoch) {
      print('\u001b[1;93mediting hw from hive: ${fireHw.toString()}');

      firestoreService.editHomeworks([localHw.copyWith(fireId: fireHw.fireId)]);
    }
    return;
  }
}
