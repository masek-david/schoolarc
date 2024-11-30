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

  late final Map<int, SubjectDTO> _subjectsDbIndex = subjectService.getMap();

  /// key is the dbIndex
  late Map<int, Homework> _hwDbIndexMap = _db.getDatabase();

  /// key is the priority, for each priority is a list of dbIndexes
  late Map<int, List<int>> _sequence = _db.getSequence();

  /// map with dbIndex and index in sequence, to return them to correct position
  final Map<int, int> completedHws = {};

  Homework? lastlyDeletedHw;
  int? lastlyDeletedHwDbIndex;
  int? lastlyDeletedHwIndex;

  void changeCompletion(int dbIndex, bool value) {
    _db.changeCompletion(dbIndex, value);

    Homework hw = _hwDbIndexMap[dbIndex]!;

    // if it is now completed
    if (value) {
      completedHws[dbIndex] = _sequence[hw.priority]!.indexOf(dbIndex);
      _sequence[hw.priority]!.remove(dbIndex);
    } else {
      // if it is now uncompleted
      int indexToInsertTo =
          completedHws[dbIndex] ?? _sequence[hw.priority]!.length;

      var list = _sequence[hw.priority]!;
      list.insert(indexToInsertTo > list.length ? list.length : indexToInsertTo,
          dbIndex);
      completedHws.remove(dbIndex);
    }

    _db.saveSequence(_sequence);
    NotificationSender.scheduleTommorrowNotification();
  }

  /// edits the position and priority of a homework at the provided index
  Future<void> changeSequence(
      int oldIndex, int oldPriority, int newIndex, int newPriority) async {
    int movedHwDbIndex = _sequence[oldPriority]![oldIndex];
    Homework movedHw = _hwDbIndexMap[movedHwDbIndex]!;
    movedHw.priority = newPriority;
    await _db.editHw(movedHwDbIndex, movedHw);
    _sequence[oldPriority]!.removeAt(oldIndex);
    _sequence[newPriority]!.insert(newIndex, movedHwDbIndex);
    await _db.saveSequence(_sequence);
    NotificationSender.scheduleTommorrowNotification();

    return;
  }

  List<TaskPriority> getPriorities(BuildContext? context) {
    List<TaskPriority> priorities = [];

    for (int i = 0; i < 4; i++) {
      priorities.add(TaskPriority(i, context));
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
    Map<DateTime, List<HomeworkDTO>> hwDateMap = {};
    _hwDbIndexMap = _db.getDatabase();
    final priorities = getPriorities(context);

    _hwDbIndexMap.forEach(
      (dbIndex, homework) {
        final hwDeadlineUtc = homework.deadline;

        DateTime dateNoTime = DateTime.utc(
            hwDeadlineUtc.year, hwDeadlineUtc.month, hwDeadlineUtc.day);

        if (hwDateMap.containsKey(dateNoTime)) {
          // If it exists, add the event to the existing list
          hwDateMap[dateNoTime]!.add(
            homework.convertToDTO(
              dbIndex,
              _subjectsDbIndex[homework.subjectDbIndex],
              priorities[homework.priority],
            ),
          );
        } else {
          // If it does not exist, create a new list with the exam
          hwDateMap[dateNoTime] = [
            homework.convertToDTO(
              dbIndex,
              _subjectsDbIndex[homework.subjectDbIndex],
              priorities[homework.priority],
            )
          ];
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
    _hwDbIndexMap = _db.getDatabase();
    _sequence = _db.getSequence();
    final priorities = getPriorities(context);

    Map<int, List<HomeworkDTO>> hwPriorityMap = {
      0: <HomeworkDTO>[],
      1: <HomeworkDTO>[],
      2: <HomeworkDTO>[],
      3: <HomeworkDTO>[],
    };

    _sequence.forEach((priority, list) {
      for (int i = 0; i < list.length; i++) {
        Homework hw = _hwDbIndexMap[list[i]]!;
        if (!hw.completion) {
          hwPriorityMap[priority]!.add(
            hw.convertToDTO(list[i], _subjectsDbIndex[hw.subjectDbIndex],
                priorities[hw.priority]),
          );
        }
      }
    });

    return hwPriorityMap;
  }

  List<HomeworkDTO> getCompletedHw(BuildContext? context) {
    List<HomeworkDTO> completedHw = [];
    _hwDbIndexMap = _db.getDatabase();
    final priorities = getPriorities(context);

    _hwDbIndexMap.forEach(
      (dbIndex, hw) {
        if (hw.completion) {
          completedHw.add(
            hw.convertToDTO(
              dbIndex,
              _subjectsDbIndex[hw.subjectDbIndex],
              priorities[hw.priority],
            ),
          );
        }
      },
    );

    return completedHw;
  }

  List<HomeworkDTO> getMissedHw(BuildContext? context) {
    List<HomeworkDTO> missedHw = [];
    _hwDbIndexMap = _db.getDatabase();
    final priorities = getPriorities(context);

    _hwDbIndexMap.forEach(
      (dbIndex, hw) {
        if (hw.deadline.isBeforeToday() && !hw.completion) {
          missedHw.add(
            hw.convertToDTO(
              dbIndex,
              _subjectsDbIndex[hw.subjectDbIndex],
              priorities[hw.priority],
            ),
          );
        }
      },
    );

    return missedHw;
  }

  /// deletes howework and saves it for reverting
  void deleteHw(int dbIndex) {
    lastlyDeletedHw = _db.getHomework(dbIndex);
    lastlyDeletedHwDbIndex = dbIndex;
    lastlyDeletedHwIndex =
        _sequence[lastlyDeletedHw!.priority]!.indexOf(dbIndex);

    _sequence[lastlyDeletedHw!.priority]!.remove(dbIndex);
    _db.saveSequence(_sequence);

    _db.deleteHw(dbIndex);
    _hwDbIndexMap.remove(dbIndex);

    NotificationSender.scheduleTommorrowNotification();
  }

  void revertLastlyDeletedHw() {
    if (lastlyDeletedHw != null &&
        lastlyDeletedHwIndex != null &&
        lastlyDeletedHwDbIndex != null) {
      _db.editHw(lastlyDeletedHwDbIndex!, lastlyDeletedHw!);
      if (!lastlyDeletedHw!.completion) {
        _sequence[lastlyDeletedHw!.priority]!
            .insert(lastlyDeletedHwIndex!, lastlyDeletedHwDbIndex!);
      }
      _hwDbIndexMap[lastlyDeletedHwDbIndex!] = lastlyDeletedHw!;
      _db.saveSequence(_sequence);

      lastlyDeletedHw = null;
      lastlyDeletedHwIndex = null;
      lastlyDeletedHwDbIndex = null;
    }

    NotificationSender.scheduleTommorrowNotification();
  }

  /// saves new homework and puts it at the end of the sequence of correct priority
  Future<void> saveNewHW({
    required DateTime date,
    required int priority,
    required SubjectDTO? subject,
    required String text,
  }) async {
    Homework newHw = Homework(
      subjectDbIndex: subject?.dbIndex,
      text: text,
      deadline: date,
      completion: false,
      priority: priority,
    );
    int dbIndex = await _db.addHw(newHw);
    _hwDbIndexMap[dbIndex] = newHw;
    _sequence[priority]!.add(dbIndex);
    await _db.saveSequence(_sequence);

    NotificationSender.scheduleTommorrowNotification();

    return;
  }

  /// saves edited homework and changes its position in sequence if necessary, cant edit completion
  Future<void> saveEditedHW({
    required DateTime date,
    required int priority,
    required SubjectDTO? subject,
    required String text,
    // required bool completion,
    required int dbIndex,
  }) async {
    int oldPriority = _hwDbIndexMap[dbIndex]!.priority;
    
    Homework editedHw = Homework(
      subjectDbIndex: subject?.dbIndex,
      text: text,
      deadline: date,
      completion: _hwDbIndexMap[dbIndex]!.completion,
      priority: priority,
    );
    await _db.editHw(dbIndex, editedHw);
    _hwDbIndexMap.update(
      dbIndex,
      (value) => editedHw,
    );

    if (oldPriority != editedHw.priority) {
      _sequence[oldPriority]!.remove(dbIndex);
      _sequence[editedHw.priority]!.add(dbIndex);
      _db.saveSequence(_sequence);
    }

    return;
  }

  HomeworkDTO getHomework(int dbIndex, BuildContext? context) {
    Homework hw = _db.getHomework(dbIndex);

    return hw.convertToDTO(
      dbIndex,
      _subjectsDbIndex[hw.subjectDbIndex],
      TaskPriority(hw.priority, context),
    );
  }

  /// returns the number of incomplete homeworks
  int getNumberOfIncomplete() {
    _hwDbIndexMap = _db.getDatabase();
    int numberOfUncomplete = 0;

    _hwDbIndexMap.forEach(
      (dbIndex, value) {
        if (!value.completion) {
          numberOfUncomplete++;
        }
      },
    );

    return numberOfUncomplete;
  }
}
