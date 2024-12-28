import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/services/homeworks/hw_database.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/utils/notifications/notification_sender.dart';
import 'package:school_manager/tasks_app.dart';

class HomeworkService {
  final HomeworksDatabase _db = HomeworksDatabase();

  /// key is the dbIndex
  late Map<int, Homework> _hwDbIndexMap = _db.getDatabase();

  /// key is the priority, for each priority is a list of dbIndexes
  late Map<int, List<int>> _sequence = _db.getSequence();

  /// map with dbIndex and index in sequence, to return them to correct position
  final Map<int, int> hwsRemovedFromSequence = {};

  Homework? lastlyDeletedHw;
  int? lastlyDeletedHwDbIndex;
  int? lastlyDeletedHwIndex;

  Future<void> changeCompletion(HomeworkDTO hw, bool value) async {
    return edit(
      hw
          .copyWith(
            timestamp: Timestamp.now(),
            completion: value,
          )
          .convert(),
      hw.dbIndex,
    );
  }

  /// edits the position and priority of a homework at the provided index
  Future<void> changeSequence(
    int oldIndex,
    int oldPriority,
    int newIndex,
    int newPriority,
  ) async {
    int movedHwDbIndex = _sequence[oldPriority]![oldIndex];
    Homework movedHw = _hwDbIndexMap[movedHwDbIndex]!;
    movedHw.priority = newPriority;
    await _db.editHw(
      movedHwDbIndex,
      movedHw.copyWith(timestamp: DateTime.now()),
    );
    _sequence[oldPriority]!.removeAt(oldIndex);
    _sequence[newPriority]!.insert(newIndex, movedHwDbIndex);
    await _db.saveSequence(_sequence);
    NotificationSender.scheduleTommorrowNotification();

    return;
  }

  /// returns even deleted
  List<HomeworkDTO> getAll(BuildContext? context) {
    final Map<int, SubjectDTO> subjectDbIndex = subjectService.getMap();

    List<HomeworkDTO> list = [];
    _hwDbIndexMap = _db.getDatabase();
    final priorities = _getPriorities(context);

    _hwDbIndexMap.forEach(
      (dbIndex, hw) {
        list.add(
          hw.convertToDTO(
            dbIndex,
            subjectDbIndex[hw.subjectDbIndex],
            priorities[hw.priority],
          ),
        );
      },
    );

    return list;
  }

  List<TaskPriority> _getPriorities(BuildContext? context) {
    List<TaskPriority> priorities = [];

    for (int i = 0; i < 4; i++) {
      priorities.add(TaskPriority(i));
    }

    return priorities;
  }

  List<HomeworkDTO> getForDay(DateTime date, BuildContext? context) {
    final dateUtc = date.toUtc();
    final hwByDate = sortByDate(context);

    final dateNoTime = DateTime.utc(dateUtc.year, dateUtc.month, dateUtc.day);

    return hwByDate[dateNoTime] ?? [];
  }

  /// returns map with datetime being only the date in UTC, not the time
  Map<DateTime, List<HomeworkDTO>> sortByDate(BuildContext? context) {
    final Map<int, SubjectDTO> subjectDbIndex = subjectService.getMap();

    Map<DateTime, List<HomeworkDTO>> hwDateMap = {};
    _hwDbIndexMap = _db.getDatabase();
    final priorities = _getPriorities(context);

    _hwDbIndexMap.forEach(
      (dbIndex, homework) {
        final hwDeadlineUtc = homework.deadline;

        DateTime dateNoTime = DateTime.utc(
            hwDeadlineUtc.year, hwDeadlineUtc.month, hwDeadlineUtc.day);

        if (!homework.isDeleted) {
          if (hwDateMap.containsKey(dateNoTime)) {
            // If it exists, add the event to the existing list
            hwDateMap[dateNoTime]!.add(
              homework.convertToDTO(
                dbIndex,
                subjectDbIndex[homework.subjectDbIndex],
                priorities[homework.priority],
              ),
            );
          } else {
            // If it does not exist, create a new list with the exam
            hwDateMap[dateNoTime] = [
              homework.convertToDTO(
                dbIndex,
                subjectDbIndex[homework.subjectDbIndex],
                priorities[homework.priority],
              )
            ];
          }
        }
      },
    );

    hwDateMap.forEach((key, value) {
      value.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    });

    return hwDateMap;
  }

  /// returns list of sorted homeworks for each priority
  Map<int, List<HomeworkDTO>> sortByPriority(BuildContext? context) {
    final Map<int, SubjectDTO> subjectDbIndex = subjectService.getMap();

    _hwDbIndexMap = _db.getDatabase();
    _sequence = _db.getSequence();
    final priorities = _getPriorities(context);

    Map<int, List<HomeworkDTO>> hwPriorityMap = {
      0: <HomeworkDTO>[],
      1: <HomeworkDTO>[],
      2: <HomeworkDTO>[],
      3: <HomeworkDTO>[],
    };

    _sequence.forEach((priority, list) {
      for (int i = 0; i < list.length; i++) {
        Homework hw = _hwDbIndexMap[list[i]]!;
        if (!hw.completion && !hw.isDeleted) {
          hwPriorityMap[priority]!.add(
            hw.convertToDTO(list[i], subjectDbIndex[hw.subjectDbIndex],
                priorities[hw.priority]),
          );
        }
      }
    });

    return hwPriorityMap;
  }

  List<HomeworkDTO> getCompletedHw(BuildContext? context) {
    final Map<int, SubjectDTO> subjectDbIndex = subjectService.getMap();

    List<HomeworkDTO> completedHw = [];
    _hwDbIndexMap = _db.getDatabase();
    final priorities = _getPriorities(context);

    _hwDbIndexMap.forEach(
      (dbIndex, hw) {
        if (hw.completion && !hw.isDeleted) {
          completedHw.add(
            hw.convertToDTO(
              dbIndex,
              subjectDbIndex[hw.subjectDbIndex],
              priorities[hw.priority],
            ),
          );
        }
      },
    );

    return completedHw;
  }

  List<HomeworkDTO> getMissedHw(BuildContext? context) {
    final Map<int, SubjectDTO> subjectDbIndex = subjectService.getMap();

    List<HomeworkDTO> missedHw = [];
    _hwDbIndexMap = _db.getDatabase();
    final priorities = _getPriorities(context);

    _hwDbIndexMap.forEach(
      (dbIndex, hw) {
        if (hw.deadline.isBeforeToday() && !hw.completion && !hw.isDeleted) {
          missedHw.add(
            hw.convertToDTO(
              dbIndex,
              subjectDbIndex[hw.subjectDbIndex],
              priorities[hw.priority],
            ),
          );
        }
      },
    );

    return missedHw;
  }

  Future<void> delete(HomeworkDTO hw) {
    return edit(
        hw
            .copyWith(
              isDeleted: true,
              timestamp: Timestamp.now(),
            )
            .convert(),
        hw.dbIndex);
  }

  Future<void> revertDelete(int dbIndex) {
    final hw = _db.getHomework(dbIndex);

    return edit(
        hw.copyWith(
          isDeleted: false,
          timestamp: DateTime.now(),
        ),
        dbIndex);
  }

  /// returns id for the new hw
  Future<int> saveNew(Homework hw) async {
    final newHwId = await _db.addHw(hw);

    _hwDbIndexMap[newHwId] = hw;
    if (!hw.isDeleted && !hw.completion) {
      _sequence[hw.priority]!.add(newHwId);
      await _db.saveSequence(_sequence);
    }

    NotificationSender.scheduleTommorrowNotification();
    return newHwId;
  }

  Future<void> edit(Homework hw, int dbIndex) async {
    int oldPriority = _db.getHomework(dbIndex).priority;
    bool oldCompletion = _db.getHomework(dbIndex).completion;
    bool oldIsDeleted = _db.getHomework(dbIndex).isDeleted;

    _sequence = _db.getSequence();

    await _db.editHw(dbIndex, hw);
    _hwDbIndexMap.update(
      dbIndex,
      (value) => hw,
    );

    if (hw.isDeleted != oldIsDeleted || hw.completion != oldCompletion) {
      if (hw.isDeleted || hw.completion) {
        // we need to remove it from sequence and save where it was
        hwsRemovedFromSequence[dbIndex] =
            _sequence[hw.priority]!.indexOf(dbIndex);
        _sequence[oldPriority]!.remove(dbIndex);
      } else {
        // if it isnt deleted and isnt completed, we need to add it back to sequence
        int indexToInsertTo =
            hwsRemovedFromSequence[dbIndex] ?? _sequence[hw.priority]!.length;

        var list = _sequence[hw.priority]!;
        list.insert(
            indexToInsertTo > list.length || indexToInsertTo < 0
                ? list.length
                : indexToInsertTo,
            dbIndex);
        hwsRemovedFromSequence.remove(dbIndex);
      }
      _db.saveSequence(_sequence);
    }
    // if priority changes we need to edit it in sequence
    if (hw.priority != oldPriority && !hw.isDeleted && !hw.completion) {
      _sequence[oldPriority]!.remove(dbIndex);
      _sequence[hw.priority]!.add(dbIndex);
      _db.saveSequence(_sequence);
    }

    NotificationSender.scheduleTommorrowNotification();
    return;
  }

  HomeworkDTO getHomework(int dbIndex, BuildContext? context) {
    final Map<int, SubjectDTO> subjectDbIndex = subjectService.getMap();

    Homework hw = _db.getHomework(dbIndex);

    return hw.convertToDTO(
      dbIndex,
      subjectDbIndex[hw.subjectDbIndex],
      TaskPriority(hw.priority),
    );
  }

  /// returns the number of incomplete homeworks
  int getNumberOfIncomplete() {
    _hwDbIndexMap = _db.getDatabase();
    int numberOfUncomplete = 0;

    _hwDbIndexMap.forEach(
      (dbIndex, hw) {
        if (!hw.completion && !hw.isDeleted) {
          numberOfUncomplete++;
        }
      },
    );

    return numberOfUncomplete;
  }
}
