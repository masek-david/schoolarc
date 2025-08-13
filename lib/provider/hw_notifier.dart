import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:riverpod/riverpod.dart';
import 'package:schoolarc/database/hive/hive_init.dart';
import 'package:schoolarc/models/homeworks/homework_entity_id_model.dart';
import 'package:schoolarc/models/homeworks/hw_entity_model.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/models/subjects/subject_model.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/firebase_activity_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/services/firebase/firebase_service.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/globals.dart';

final hwProvider =
    NotifierProvider<HwNotifier, Map<String, Homework>>(HwNotifier.new);

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

// key for each day is the utc value, with time being 0:00:00
final hwDatesProvider = Provider<Map<DateTime, List<Homework>>>(
  (ref) {
    final hws = ref.watch(hwProvider);

    return hwsSortByDate(hws);
  },
);

/// key for each day is the local date value, with time being 0:00:00
Map<DateTime, List<Homework>> hwsSortByDate(Map<String, Homework> original) {
  Map<DateTime, List<Homework>> hwDateMap = {};

  original.forEach(
    (dbIndex, homework) {
      final hwDeadlineLocal = homework.deadline.toLocal();

      DateTime dateNoTime = DateTime(
          hwDeadlineLocal.year, hwDeadlineLocal.month, hwDeadlineLocal.day);

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
    value.sort((a, b) => a.id.compareTo(b.id));
    value.sort((a, b) => b.priority.index.compareTo(a.priority.index));
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
    final hws = ref.watch(hwSortedProvider);
    final list = <Homework>[];

    for (int i = 3; i >= 0; i--) {
      list.addAll([...hws[i]!]);
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

List<Homework> hwsGetMissed(Map<String, Homework> original) {
  List<Homework> missedHw = [];

  original.forEach(
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
}

class HwNotifier extends Notifier<Map<String, Homework>>
    with WidgetsBindingObserver {
  Map<String, Subject> subjects = {};
  StreamSubscription<HomeworkEntityWithID>? listenFirebase;

  @override
  Map<String, Homework> build() {
    // listen to subjectsProvider changes
    ref.listen(subjectsNonDeletedProvider, (_, next) {
      subjects = next;
      _loadState();
    });
    subjects = ref.read(subjectsNonDeletedProvider);

    listenToFirebase();
    _checkForDeleted();

    WidgetsBinding.instance.addObserver(this);
    return _dbState;
  }

  void _loadState() {
    state = _dbState;
  }

  /// returns state saved in database
  Map<String, Homework> get _dbState {
    return homeworksDb.getDatabase().map(
      (key, value) {
        return MapEntry(
          key,
          value.convert(key, subjects[value.subjectId]),
        );
      },
    );
  }

  // when reopening app, reload hive, to check for modified homework, only on android
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed && !kIsWeb && Platform.isAndroid) {
      try {
        await Hive.box(hwBox).close();
      } on Object {
        // it shouldnt matter
      }
      await Hive.openBox(hwBox);

      _loadState();
    }
  }

  Future<void> listenToFirebase() async {
    await listenFirebase?.cancel();

    listenFirebase = ref.read(firebaseServiceProvider).listenHomeworks().listen(
        (event) async {
      ref.read(firebaseActivityProvider.notifier).read(1);

      if (!Hive.box(hwBox).isOpen) {
        await Hive.openBox(hwBox);
      }

      await checkFireHomework(event);
    }, onError: (error) {
      log('error listening to firebase hws: ${error.toString()}');
    });
  }

  /// checks all online and offline
  Future<void> syncAll() async {
    _loadState();
    await listenToFirebase();
    final fireHws = await ref.read(firebaseServiceProvider).getAllHomeworks();

    fireHws?.forEach(
      (element) async {
        await checkFireHomework(element);
      },
    );

    await _checkForDeleted();
    _loadState();

    state.forEach(
      (key, value) {
        bool isSynced = fireHws
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
    HomeworkEntity hw, {
    // if null, new id is generated
    String? overrideId,
    bool addToFire = true,
    // sets the order to put the task to the end
    bool addToEnd = true,
  }) async {
    if (addToEnd) {
      hw = hw.copyWith(
          order: _dbState.values
              .where(
                (element) =>
                    !element.isDeleted &&
                    !element.isCompleted &&
                    element.priority.index == hw.priority,
              )
              .length);
    }

    final id = overrideId ?? uuid.v4();

    final originalState = _dbState;
    await homeworksDb.addHw(id, hw);

    final Homework? hwWithSameOrder = originalState.values
        .where((element) =>
            element.order == hw.order &&
            !element.isDeleted &&
            !element.isCompleted)
        .firstOrNull;

    if (!hw.isCompleted && !hw.isDeleted) {
      if (hwWithSameOrder != null && !addToEnd) {
        if (hw.timestamp.millisecondsSinceEpoch <
            hwWithSameOrder.timestamp.millisecondsSinceEpoch) {
          // if the new one is older, add it after the old one
          hw = hw.copyWith(order: hw.order + 1);
          homeworksDb.editHw(id, hw);
          // if the new one is newer, add it before old
        }
        reorder(
          hw.order,
          hw.priority,
          hw.convert(id, subjects[hw.subjectId]),
        );
      }
    }

    state = {...state, id: hw.convert(id, subjects[hw.subjectId])};

    if (addToFire) {
      await ref
          .read(firebaseServiceProvider)
          .addHomework(hw.convert(id, subjects[hw.subjectId]));
    }

    return;
  }

  /// assign timestamp manually, if no id, it will add it as now
  Future<void> edit(
    Homework editedHw, {
    bool syncWithFire = true,

    /// this is true when completing a task, it wont reorder others
    bool disableReorder = false,
  }) async {
    final old = _dbState[editedHw.id]!;

    if (!disableReorder) {
      // if it wasnt and isnt in the sorted view (if it is and was deleted or is and was completed), dont sort
      if (!((editedHw.isDeleted && old.isDeleted) ||
          (editedHw.isCompleted && old.isCompleted))) {
        // if now is deleted or now is completed (should hide)
        if ((editedHw.isDeleted && !old.isDeleted) ||
            (editedHw.isCompleted && !old.isCompleted)) {
          reorder(
            null,
            null,
            old,
          );
        }
        // if now isnt deleted or now isnt completed (should appear)
        if ((!editedHw.isDeleted && old.isDeleted) ||
            (!editedHw.isCompleted && old.isCompleted)) {
          reorder(
            editedHw.order,
            editedHw.priority.index,
            editedHw,
          );
        }

        // if order has been changed
        if (old.order != editedHw.order ||
            old.priority.index != editedHw.priority.index) {
          await reorder(
            editedHw.order,
            editedHw.priority.index,
            old,
          );
        }
      }
    }

    await homeworksDb.editHw(editedHw.id, editedHw.convert());

    if (syncWithFire) {
      ref.read(firebaseServiceProvider).editHomeworks([editedHw]);
    }

    final isNew = editedHw.timestamp.difference(DateTime.now()) <
        const Duration(seconds: 5);
    final bool shouldPlayAnimation =
        old.isCompleted == false && editedHw.isCompleted == true && isNew;

    if (shouldPlayAnimation) {
      state = {
        ...state,
        editedHw.id: editedHw.copyWith(isBeingAnimated: true),
      };

      await Future.delayed(const Duration(seconds: 1));
      // remove the animation only if it was this call of this method that set the animation to true the first
      if (state[editedHw.id]!.timestamp == editedHw.timestamp) {
        state = {
          ...state,
          editedHw.id: state[editedHw.id]!.copyWith(isBeingAnimated: false),
        };
      }
    } else {
      state = {
        ...state,
        editedHw.id: editedHw.copyWith(isBeingAnimated: false)
      };
    }
  }

  /// updates all with changed order
  ///
  /// [originalHw] is old homework, [newIndex] and [newPriority] are where it will be placed
  ///
  /// timestamp updated only for the moved subject if [addTimestamp] is true, which is only when it is called from the UI
  Future<void> reorder(
    int? newIndex,
    int? newPriority,
    final Homework originalHw, {
    bool addTimestamp = false,
  }) async {
    // both must be null or both mustnt be null
    assert((newIndex == null) == (newPriority == null));

    var oldPriorityList = _dbState.values
        .where(
          (element) =>
              !element.isDeleted &&
              !element.isCompleted &&
              element.priority.index == originalHw.priority.index,
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

    // if you can remove it from somewhere
    oldPriorityList.removeWhere((element) => element.id == originalHw.id);
    // if you arent changing priority, you need to remove it from the [newPriorityList] too
    newPriorityList.removeWhere((element) => element.id == originalHw.id);

    Homework newHomework = originalHw;
    if (addTimestamp) {
      newHomework = newHomework.copyWith(timestamp: DateTime.now().toUtc());
    }

    // if you want to add it somewhere
    if (newIndex != null && newPriority != null) {
      // change the task's priority
      newHomework = newHomework.copyWith(priority: TaskPriority(newPriority));
      // add it to list of [newPriority], at [newIndex]
      newPriorityList.insert(
          newIndex > newPriorityList.length ? newPriorityList.length : newIndex,
          newHomework);
    }

    // now the lists are final, its just about saving all homeworks with changed values

    final editedHomeworks = <String, Homework>{};

    // if priority has changed, check old list too
    if (originalHw.priority.index != newPriority) {
      for (int i = 0; i < oldPriorityList.length; i++) {
        final edited = oldPriorityList[i].copyWith(order: i);
        final oldHw = _dbState[edited.id];

        if (edited.order != oldHw?.order) {
          editedHomeworks[edited.id] = edited;
        }
      }
    }
    for (int i = 0; i < newPriorityList.length; i++) {
      final edited = newPriorityList[i].copyWith(order: i);
      final oldHw = _dbState[edited.id];

      if (edited.order != oldHw?.order ||
          edited.priority.index != oldHw?.priority.index) {
        editedHomeworks[edited.id] = edited;
      }
    }

    editedHomeworks.forEach(
      (key, value) async {
        homeworksDb.editHw(value.id, value.convert());
      },
    );

    ref
        .read(firebaseServiceProvider)
        .editHomeworks(editedHomeworks.values.toList());

    state = {...state, ...editedHomeworks};
    return;
  }

  void convert(Homework hw) {
    delete(hw);
    ref.read(examProvider.notifier).saveNew(hw.toExamEntity());
  }

  Future<void> completeById(String id, bool nowIsCompleted) async {
    final hw = _dbState[id];

    if (hw != null) {
      await complete(hw, nowIsCompleted);
    }
  }

  Future<void> complete(Homework hw, bool nowIsCompleted) async {
    await edit(
      hw.copyWith(
          timestamp: DateTime.now().toUtc(), isCompleted: nowIsCompleted),
      disableReorder: nowIsCompleted,
    );
  }

  void delete(Homework hw) {
    edit(hw.copyWith(timestamp: DateTime.now().toUtc(), isDeleted: true));
  }

  void revertDelete(Homework hw) {
    edit(
      hw.copyWith(
          timestamp: DateTime.now().toUtc(),
          isDeleted: false,
          stateReaddingVersion: hw.stateReaddingVersion + 1),
    );
  }

  /// `_permanentDelete` must be called from build(), because it doesnt update the state
  Future<void> _permanentDelete(List<Homework> hws) async {
    if (hws.isEmpty) return;
    for (var element in hws) {
      homeworksDb.deleteHw(element.id);
    }
    await ref.read(firebaseServiceProvider).deleteHomeworks(hws);
  }

  /// `_checkForDeleted` must be called from build(), because it doesnt update the state
  Future<void> _checkForDeleted() async {
    final now = DateTime.now();
    List<Homework> hwsToDelete = [];

    for (var hw in _dbState.values) {
      if (hw.isDeleted &&
          now.difference(hw.timestamp) > const Duration(days: 7)) {
        hwsToDelete.add(hw);
      }
    }
    await _permanentDelete(hwsToDelete);
  }

  /// checks and updates/adds hw from firestore, overwrites the newest version
  Future<void> checkFireHomework(HomeworkEntityWithID fireHw) async {
    // print('checking hw from fire: ${fireHw.toString()}');

    final localHw = _dbState.values.where(
      (element) {
        return element.id == fireHw.id;
      },
    ).firstOrNull;

    // if it doesnt exist in local, add it
    if (localHw == null) {
      // print('\u001b[1;92madding hw from fire: ${fireHw.toString()}');

      await saveNew(
        fireHw,
        overrideId: fireHw.id,
        addToFire: false,
        addToEnd: false,
      );
      return;
    }

    final localTime = localHw.timestamp;
    final fireTime = fireHw.timestamp;

    if (fireTime.millisecondsSinceEpoch > localTime.millisecondsSinceEpoch) {
      // print('\u001b[1;93mediting hw from fire: ${fireHw.toString()}');

      edit(
        fireHw.convert(fireHw.id, subjects[fireHw.subjectId]),
        syncWithFire: false,
      );
    } else if (fireTime.millisecondsSinceEpoch <
        localTime.millisecondsSinceEpoch) {
      // print('\u001b[1;93mediting hw from hive: ${fireHw.toString()}');

      ref
          .read(firebaseServiceProvider)
          .editHomeworks([localHw.copyWith(id: fireHw.id)]);
    }
    return;
  }
}
