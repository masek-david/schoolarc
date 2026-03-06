import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod/riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/homeworks/hw_data_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/firebase/firebase_activity_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/utils/globals.dart';

final hwDataProvider = NotifierProvider<HwNotifier, Map<String, HomeworkData>>(
  HwNotifier.new,
);

final hwProvider = Provider<Map<String, Homework>>(
  (ref) {
    final hws = ref.watch(hwDataProvider);
    final subjects = ref.watch(subjectsNonDeletedProvider);

    return hws.map(
      (key, value) => MapEntry(
        key,
        value.convert(subjects[value.subjectId]),
      ),
    );
  },
);

// sorts by priorities (0-3), orders them
final hwSortedProvider = Provider<Map<int, List<Homework>>>(
  (ref) {
    final hws = ref.watch(hwProvider);

    Map<int, List<Homework>> hwPriorityMap = {
      0: <Homework>[],
      1: <Homework>[],
      2: <Homework>[],
      3: <Homework>[],
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

final hwDatesProvider = Provider<Map<Date, List<Homework>>>(
  (ref) {
    final hws = ref.watch(hwProvider);

    return hwsSortByDate(hws);
  },
);

Map<Date, List<Homework>> hwsSortByDate(Map<String, Homework> original) {
  Map<Date, List<Homework>> hwDateMap = {};

  original.forEach(
    (dbIndex, homework) {
      final date = homework.date;

      if (!homework.isDeleted) {
        if (hwDateMap.containsKey(date)) {
          // If it exists, add the event to the existing list
          hwDateMap[date]!.add(homework);
        } else {
          // If it does not exist, create a new list with the exam
          hwDateMap[date] = [homework];
        }
      }
    },
  );

  hwDateMap.forEach((key, value) {
    value.sort(
      (a, b) => b.priority.index.compareTo(a.priority.index) != 0
          ? b.priority.index.compareTo(a.priority.index)
          : a.id.compareTo(b.id),
    );
  });

  return hwDateMap;
}

final hwCompletedProvider = Provider<List<Homework>>(
  (ref) {
    final hws = ref.watch(hwProvider);

    final list = <Homework>[];

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

final hwWidgetProvider = Provider<List<Homework>>(
  (ref) {
    final hws = ref.watch(hwProvider);
    final list = <Homework>[];

    for (final hw in hws.values) {
      if (!hw.isDeleted && !hw.date.isBefore(Date.today())) {
        list.add(hw);
      }
    }
    return list;
  },
);

final hwMissedProvider = Provider<List<Homework>>(
  (ref) {
    final hws = ref.watch(hwProvider);

    return hwsGetMissed(hws);
  },
);

final hwDeletedProvider = Provider<List<Homework>>(
  (ref) {
    final hws = ref.watch(hwProvider);

    final list = hws.values
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

/// Returns homework that isnt completed and should be completed before [missedBy]
///
/// [missedBy] is defaultly today
List<Homework> hwsGetMissed(Map<String, Homework> original, {Date? missedBy}) {
  List<Homework> missedHw = [];

  original.forEach(
    (dbIndex, hw) {
      if (hw.date.isBefore(missedBy ?? Date.today()) &&
          !hw.isDeleted &&
          (!hw.isCompleted || hw.isBeingAnimated)) {
        missedHw.add(hw);
      }
    },
  );

  missedHw.sort((a, b) => a.date.compareTo(b.date));
  return missedHw;
}

class HwNotifier extends Notifier<Map<String, HomeworkData>> {
  Map<String, Subject> subjects = {};
  StreamSubscription<HomeworkData>? listenFirebase;

  @override
  Map<String, HomeworkData> build() {
    listenToFirebase();
    Future.microtask(() => _checkForDeleted());

    return _dbState;
  }

  /// returns state saved in database
  Map<String, HomeworkData> get _dbState {
    return homeworksDb.readDatabase().map(
      (key, value) {
        return MapEntry(key, value.toData(key));
      },
    );
  }

  Future<void> listenToFirebase() async {
    await listenFirebase?.cancel();

    listenFirebase = fireService.listenHomeworks().listen(
      (event) async {
        ref.read(firebaseActivityProvider.notifier).read(1);

        await checkFireHomework(event);
      },
      onError: (error) {
        log('error listening to firebase hws: ${error.toString()}');
      },
    );
  }

  /// checks all online and offline, starts listening to firebase
  Future<void> syncAll() async {
    await listenToFirebase();
    final fireHws = await fireService.getAllHomeworks();

    fireHws?.forEach(
      (element) async {
        await checkFireHomework(element);
      },
    );

    state.forEach(
      (id, hw) {
        bool isSynced =
            fireHws
                ?.where(
                  (element) => element.id == id,
                )
                .firstOrNull !=
            null;

        if (!isSynced) {
          update(hw);
        }
      },
    );
  }

  /// If [addToEnd] is true, order will be set to end of the list of its priority
  Future<void> create(
    HomeworkData hw, {
    bool syncWithFire = true,
    bool addToEnd = true,
  }) async {
    if (addToEnd) {
      hw = hw.copyWith(
        order: _getOrder(
          index: null,
          priority: hw.priority,
          id: null,
        ),
      );
    }

    final id = uuid.v4();
    hw = hw.copyWith(id: id);
    await homeworksDb.put(id, hw.toEntity());

    state = {...state, id: hw};

    if (syncWithFire) {
      await fireService.createHw(hw);
    }
  }

  /// You have to assign timestamp manually, if no id, it will add it as now
  ///
  /// [checkOrder] is false when calling from reorder, because its not neccesary to check again
  /// [checkOrder] is false when calling from checkFire, so it is synced
  Future<void> update(
    HomeworkData edited, {
    bool syncWithFire = true,
    bool checkOrder = true,
  }) async {
    final isNew =
        edited.timestamp.difference(DateTime.now()).abs() <
        const Duration(seconds: 5);
    final old = state[edited.id];
    final bool playAnimation =
        old?.isCompleted == false && edited.isCompleted && isNew;

    if (old?.priority != edited.priority &&
        !edited.isCompleted &&
        !edited.isDeleted &&
        checkOrder) {
      edited = edited.copyWith(
        order: _getOrder(
          index: null,
          priority: edited.priority,
          id: edited.id,
        ),
      );
    }

    homeworksDb.put(edited.id, edited.toEntity());
    if (syncWithFire) {
      fireService.updateHw([edited]);
    }

    if (playAnimation) {
      state = {
        ...state,
        edited.id: edited.copyWith(isBeingAnimated: true),
      };

      await Future.delayed(const Duration(seconds: 1));
      // remove the animation only if it was this call of this method that set the animation to true the first
      if (state[edited.id]!.timestamp == edited.timestamp) {
        state = {
          ...state,
          edited.id: state[edited.id]!.copyWith(isBeingAnimated: false),
        };
      }
    } else {
      state = {...state, edited.id: edited.copyWith(isBeingAnimated: false)};
    }
  }

  /// [newIndex] and [newPriority] are where the item will be placed
  ///
  /// timestamp updated automatically for the moved subject
  Future<void> reorder(
    final HomeworkData original,
    int newIndex,
    int newPriority,
  ) async {
    await update(
      original.copyWith(
        timestamp: DateTime.now(),
        priority: newPriority,
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
              element.priority == priority &&
              element.id != id,
        )
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));

    final double order;
    final isLast = index == null ? true : index >= list.length;

    if (isLast) {
      order = (list.lastOrNull?.order.ceilToDouble() ?? 0) + 1;
    } else {
      final indexBefore = index == 0
          ? 0.0
          : list.elementAtOrNull(index - 1)?.order ?? 0;
      final itemAfter = list.elementAtOrNull(index);
      final indexAfter =
          itemAfter?.order ?? list.lastOrNull?.order.ceilToDouble() ?? 0 + 1;

      // if the task after is 0.0 (could happen, old data used to be this way)
      // update that task to some higher value
      if (indexAfter == 0.0 && itemAfter != null) {
        final indexAfterAfter =
            list.elementAtOrNull(index + 1)?.order ??
            list.lastOrNull?.order.ceilToDouble() ??
            0 + 1;

        final newIndexAfter = getMiddleIndex(indexAfter, indexAfterAfter);
        update(itemAfter.copyWith(order: newIndexAfter), checkOrder: false);

        order = getMiddleIndex(indexBefore, newIndexAfter);
      } else {
        order = getMiddleIndex(indexBefore, indexAfter);
      }
    }
    return order;
  }

  /// deletes this homework and creates new exam
  void convert(HomeworkData hw) {
    _permanentDelete([hw]);
    ref.read(examDataProvider.notifier).create(hw.toExam());
  }

  Future<void> completeById(String id, bool nowIsCompleted) async {
    final hw = state[id];

    if (hw != null) {
      await complete(hw, nowIsCompleted);
    }
  }

  Future<void> complete(HomeworkData hw, bool nowIsCompleted) async {
    await update(
      hw.copyWith(
        timestamp: DateTime.now().toUtc(),
        isCompleted: nowIsCompleted,
      ),
    );
  }

  void delete(HomeworkData hw) {
    update(hw.copyWith(timestamp: DateTime.now().toUtc(), isDeleted: true));
  }

  void revertDelete(HomeworkData hw) {
    update(
      hw.copyWith(
        timestamp: DateTime.now().toUtc(),
        isDeleted: false,
        stateReaddingVersion: hw.stateReaddingVersion + 1,
      ),
    );
  }

  Future<void> _permanentDelete(List<HomeworkData> hws) async {
    if (hws.isEmpty) return;
    for (var element in hws) {
      homeworksDb.delete(element.id);
      state.remove(element.id);
    }

    state = {...state};
    await fireService.deleteHomeworks(hws);
  }

  Future<void> _checkForDeleted() async {
    final now = DateTime.now();
    List<HomeworkData> hwsToDelete = [];

    for (var hw in state.values) {
      if (hw.isDeleted &&
          now.difference(hw.timestamp) > const Duration(days: 7)) {
        hwsToDelete.add(hw);
      }
    }
    await _permanentDelete(hwsToDelete);
  }

  /// checks and updates/adds hw from firestore, overwrites the newest version
  Future<void> checkFireHomework(HomeworkData fireHw) async {
    // print('checking hw from fire: ${fireHw.toString()}');

    final localHw = state.values.where(
      (element) {
        return element.id == fireHw.id;
      },
    ).firstOrNull;

    // if it doesnt exist in local, add it
    if (localHw == null) {
      // print('\u001b[1;92madding hw from fire: ${fireHw.toString()}');

      await update(fireHw, syncWithFire: false, checkOrder: false);
      return;
    }

    final localTime = localHw.timestamp;
    final fireTime = fireHw.timestamp;

    if (fireTime.millisecondsSinceEpoch > localTime.millisecondsSinceEpoch) {
      // print('\u001b[1;93mediting hw from fire: ${fireHw.toString()}');

      update(fireHw, syncWithFire: false, checkOrder: false);
    } else if (fireTime.millisecondsSinceEpoch <
        localTime.millisecondsSinceEpoch) {
      // print('\u001b[1;93mediting hw from hive: ${fireHw.toString()}');

      fireService.updateHw([
        localHw.copyWith(id: fireHw.id),
      ]);
    }
    return;
  }
}
