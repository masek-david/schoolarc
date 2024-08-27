import 'package:school_manager/data/homeworks_data/hw_database.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/data/homeworks_data/hw_model.dart';

class ServiceHW {
  final HomeworksDatabase _db = HomeworksDatabase();
  Map<int, Homework> _hwDbIndexMap = {};
  Map<int, List<int>> _sequence = {};
  Homework? lastlyDeletedHw;
  int? lastlyDeletedHwDbIndex;
  int? lastlyDeletedHwIndex;

  void initiate() {
    _db.initiateDatabase();
    _hwDbIndexMap = _db.getDatabase();
    _sequence = _db.getSequence();
  }

  void changeCompletion(int dbIndex) {
    _db.changeCompletion(dbIndex);
  }

  /// edits the position and priority of a homework at the provided index
  void changeSequence(
      int oldIndex, int oldPriority, int newIndex, int newPriority) {
    int movedHwDbIndex = _sequence[oldPriority]![oldIndex];
    Homework movedHw = _hwDbIndexMap[movedHwDbIndex]!;
    movedHw.priority = newPriority;
    _db.editHw(movedHwDbIndex, movedHw);
    _sequence[oldPriority]!.removeAt(oldIndex);
    _sequence[newPriority]!.insert(newIndex, movedHwDbIndex);
    _db.saveSequence(_sequence);
  }

  /// returns map with datetime being only the date, not the time
  Map<DateTime, List<HomeworkDTO>> sortByDate() {
    Map<DateTime, List<HomeworkDTO>> hwDateMap = {};

    _hwDbIndexMap.forEach(
      (dbIndex, value) {
        DateTime dateNoTime = DateTime(
            value.deadline.year, value.deadline.month, value.deadline.day);
        if (hwDateMap.containsKey(dateNoTime)) {
          // If it exists, add the event to the existing list
          hwDateMap[dateNoTime]!.add(value.convertToDTO(dbIndex));
        } else {
          // If it does not exist, create a new list with the exam
          hwDateMap[dateNoTime] = [value.convertToDTO(dbIndex)];
        }
      },
    );

    hwDateMap.forEach((key, value) {
      value.sort((a, b) => b.priority.compareTo(a.priority));
    });

    return hwDateMap;
  }

  /// returns list of sorted homeworks for each priority
  Map<int, List<HomeworkDTO>> sortByPriority() {
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
          hwPriorityMap[priority]!.add(hw.convertToDTO(list[i]));
        }
      }
    });

    return hwPriorityMap;
  }

  List<HomeworkDTO> getCompletedHw() {
    List<HomeworkDTO> completedHw = [];

    _hwDbIndexMap.forEach(
      (dbIndex, hw) {
        if (hw.completion) {
          completedHw.add(hw.convertToDTO(dbIndex));
        }
      },
    );

    return completedHw;
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
  }

  void revertLastlyDeletedHw() {
    if (lastlyDeletedHw != null &&
        lastlyDeletedHwIndex != null &&
        lastlyDeletedHwDbIndex != null) {
      _db.editHw(lastlyDeletedHwDbIndex!, lastlyDeletedHw!);
      _sequence[lastlyDeletedHw!.priority]!
          .insert(lastlyDeletedHwIndex!, lastlyDeletedHwDbIndex!);
      _hwDbIndexMap[lastlyDeletedHwDbIndex!] = lastlyDeletedHw!;
      _db.saveSequence(_sequence);

      lastlyDeletedHw = null;
      lastlyDeletedHwIndex = null;
      lastlyDeletedHwDbIndex = null;
    }
  }

  /// saves new homework and puts it at the end of the sequence of correct priority
  Future<void> saveNewHW({
    required DateTime date,
    required int priority,
    required String subject,
    required String text,
  }) async {
    Homework newHw = Homework(
      subject: subject,
      text: text,
      deadline: date,
      completion: false,
      priority: priority,
    );
    int dbIndex = await _db.addHw(newHw);
    _hwDbIndexMap[dbIndex] = newHw;
    _sequence[priority]!.add(dbIndex);
    _db.saveSequence(_sequence);
    return;
  }

  /// saves edited homework and changes its position in sequence if necessary
  void saveEditedHW({
    required DateTime date,
    required int priority,
    required String subject,
    required String text,
    required bool completion,
    required int dbIndex,
  }) {
    int oldPriority = _hwDbIndexMap[dbIndex]!.priority;
    Homework editedHw = Homework(
        subject: subject,
        text: text,
        deadline: date,
        completion: completion,
        priority: priority);
    _db.editHw(dbIndex, editedHw);
    _hwDbIndexMap.update(
      dbIndex,
      (value) => editedHw,
    );

    if (oldPriority != editedHw.priority) {
      _sequence[oldPriority]!.remove(dbIndex);
      _sequence[editedHw.priority]!.add(dbIndex);
      _db.saveSequence(_sequence);
    }
  }

  HomeworkDTO getHomework(int dbIndex) {
    return _db.getHomework(dbIndex).convertToDTO(dbIndex);
  }

  /// returns the number of incomplete homeworks
  int getNumberOfIncomplete() {
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
