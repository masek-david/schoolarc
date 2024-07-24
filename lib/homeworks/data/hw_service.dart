import 'package:school_manager/homeworks/data/hw_database.dart';
import 'package:school_manager/homeworks/data/hw_dto_model.dart';
import 'package:school_manager/homeworks/data/hw_model.dart';

class ServiceHW {
  final HomeworksDatabase _db = HomeworksDatabase();
  Map<int, Homework> _hwKeyMap = {};
  Map<int, List<int>> sequence = {};
  Homework? lastlyDeletedHw;
  int? lastlyDeletedHwKey;
  int? lastlyDeletedHwIndex;

  void initiate() {
    _db.createInitialData();
    _hwKeyMap = _db.getDatabase();
    sequence = _db.getSequence();
  }

  void changeCompletion(int key) {
    _db.changeCompletion(key);
  }

  void changeSequence(
      int oldPriority, int oldIndex, int newPriority, int newIndex) {
    int movedHwKey = sequence[oldPriority]![oldIndex];
    Homework movedHw = _hwKeyMap[movedHwKey]!;
    movedHw.priority = newPriority;
    _db.editHW(movedHwKey, movedHw);
    sequence[oldPriority]!.removeAt(oldIndex);
    sequence[newPriority]!.insert(newIndex, movedHwKey);
    _db.saveSequence(sequence);
  }

  /// returns map with datetime being only the date, not the time
  Map<DateTime, List<HomeworkDTO>> sortByDate() {
    Map<DateTime, List<HomeworkDTO>> hwDateMap = {};

    _hwKeyMap.forEach(
      (key, value) {
        DateTime dateNoTime = DateTime(
            value.deadline.year, value.deadline.month, value.deadline.day);
        if (hwDateMap.containsKey(dateNoTime)) {
          // If it exists, add the event to the existing list
          hwDateMap[dateNoTime]!.add(value.convertToDTO(key));
        } else {
          // If it does not exist, create a new list with the exam
          hwDateMap[dateNoTime] = [value.convertToDTO(key)];
        }
      },
    );

    hwDateMap.forEach((key, value) {
      value.sort((a, b) => b.priority.compareTo(a.priority));
    });

    return hwDateMap;
  }

  Map<int, List<HomeworkDTO>> sortByPriority() {
    print("sorting by priority");
    Map<int, List<HomeworkDTO>> hwPriorityMap = {
      0: <HomeworkDTO>[],
      1: <HomeworkDTO>[],
      2: <HomeworkDTO>[],
      3: <HomeworkDTO>[],
    };

    sequence.forEach((priority, list) {
      for (int i = 0; i < list.length; i++) {
        Homework hw = _hwKeyMap[list[i]]!;
        if (!hw.isCompleted) {
          hwPriorityMap[priority]!.add(hw.convertToDTO(list[i]));
        }
      }
    });

    return hwPriorityMap;
  }

  List<HomeworkDTO> getCompletedHw() {
    List<HomeworkDTO> completedHw = [];

    _hwKeyMap.forEach(
      (key, value) {
        if (value.isCompleted) {
          completedHw.add(value.convertToDTO(key));
        }
      },
    );

    return completedHw;
  }

  void deleteHw(int key) {
    lastlyDeletedHw = _db.getHomework(key);
    lastlyDeletedHwKey = key;
    lastlyDeletedHwIndex = sequence[lastlyDeletedHw!.priority]!.indexOf(key);

    sequence[lastlyDeletedHw!.priority]!.remove(key);
    _db.saveSequence(sequence);
    
    _db.deleteHw(key);
    _hwKeyMap.remove(key);
  }

  void revertLastlyDeletedHw() {
    if (lastlyDeletedHw != null && lastlyDeletedHwIndex != null && lastlyDeletedHwKey != null) {
      _db.editHW(lastlyDeletedHwKey!, lastlyDeletedHw!);
      sequence[lastlyDeletedHw!.priority]!.insert(lastlyDeletedHwIndex!, lastlyDeletedHwKey!);
      _hwKeyMap[lastlyDeletedHwKey!] = lastlyDeletedHw!;
      _db.saveSequence(sequence);

      lastlyDeletedHw = null;
      lastlyDeletedHwIndex = null;
      lastlyDeletedHwKey = null;
    }
  }

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
      isCompleted: false,
      priority: priority,
    );
    int key = await _db.addHw(newHw);
    _hwKeyMap[key] = newHw;
    sequence[priority]!.add(key);
    _db.saveSequence(sequence);
    return;
  }

  void saveEditedHW({
    required DateTime date,
    required int priority,
    required String subject,
    required String text,
    required bool completion,
    required int key,
  }) {
    int oldPriority = _hwKeyMap[key]!.priority;
    Homework editedHw = Homework(
        subject: subject,
        text: text,
        deadline: date,
        isCompleted: completion,
        priority: priority);
    _db.editHW(key, editedHw);
    _hwKeyMap.update(
      key,
      (value) => editedHw,
    );

    if (oldPriority != editedHw.priority) {
      sequence[oldPriority]!.remove(key);
      sequence[editedHw.priority]!.add(key);
      _db.saveSequence(sequence);
    }
  }

  HomeworkDTO getHomework(int key) {
    return _db.getHomework(key).convertToDTO(key);
  }

  int getNumberOfIncomplete() {
    int numberOfUncomplete = 0;
    _hwKeyMap.forEach(
      (key, value) {
        if (!value.isCompleted) {
          numberOfUncomplete++;
        }
      },
    );
    return numberOfUncomplete;
  }
}
