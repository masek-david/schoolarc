import 'package:flutter/material.dart';
import 'package:school_manager/homeworks/data/hw_database.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/homeworks/data/hw_dto_model.dart';
import 'package:school_manager/homeworks/data/hw_model.dart';

class ServiceHW {
  final _myBox = Hive.box('myBox');
  HomeworksDatabase db = HomeworksDatabase();
  List<Homework> hwList = [];
  Map<int, List<HomeworkDTO>> sortedHw = {
    0: <HomeworkDTO>[],
    1: <HomeworkDTO>[],
    2: <HomeworkDTO>[],
    3: <HomeworkDTO>[],
  };

  void initiate() {
    // if first time ever opening app, create initial data
    if (_myBox.get("HOMEWORKS") == null) {
      db.createInitialData();
    } else {
      // there already exist data
      db.loadData();
    }
  }

  void changeCompletion(int index) {
    db.changeCompletion(index);
    // sortHwList();
  }

  void cleanSortedHwList() {
    for (int i = 0; i <= 3; i++) {
      sortedHw[i]!.clear();
    }
  }

  Map<int, List<HomeworkDTO>> sortHwList() {
    hwList = db.getDatabase();
    List<HomeworkDTO> indexedList = [];
    for (int index = 0; index < hwList.length; index++) {
      Homework hw = hwList[index];
      if (hw.completion == false) {
        indexedList.add(HomeworkDTO(
            subject: hw.subject,
            text: hw.text,
            deadline: hw.deadline,
            completion: hw.completion,
            priority: hw.priority,
            index: index));
      }
    }
    cleanSortedHwList();
    for (HomeworkDTO hw in indexedList) {
      var list = sortedHw[hw.priority];
      // var list je odkaz na list Homework v mape sortedHw => priradi se do mapy se spravnou prioritou
      if (list != null) {
        list.add(hw);
      }
    }
    for (int i = 0; i <= 3; i++) {
      sortedHw[i]!.sort((a, b) => a.deadline.compareTo(b.deadline));
    }
    return sortedHw;
  }

  List<HomeworkDTO> getCompletedList() {
    List<HomeworkDTO> completedHw = [];
    for (int index = hwList.length - 1; index >= 0; index--) {
      Homework hw = hwList[index];
      if (hw.completion == true) {
        completedHw.add(convertToDTO(hw, index));
      }
    }
    debugPrint('completed hw: ${completedHw.toString()}');
    return completedHw;
  }

  void deleteHw(int index) {
    db.deleteHw(index);
    sortHwList();
  }

  void saveNewHW({
    required DateTime date,
    required int priority,
    required String subject,
    required String text,
  }) {
    Homework editedHw = Homework(
        subject: subject,
        text: text,
        deadline: date,
        completion: false,
        priority: priority);
    db.addHw(editedHw);
    HomeworkDTO editedHwDto = convertToDTO(editedHw, hwList.length - 1);
    sortedHw[editedHwDto.priority]!.add(editedHwDto);
  }

  void saveEditedHW({
    required DateTime date,
    required int priority,
    required String subject,
    required String text,
    required bool completion,
    required int index,
  }) {
    Homework editedHw = Homework(
        subject: subject,
        text: text,
        deadline: date,
        completion: completion,
        priority: priority);
    db.editHW(index, editedHw);
    sortHwList();                   // musi tu byt aby se aktualizoval view
    db.updateDatabase();
  }

  HomeworkDTO convertToDTO(Homework hw, int index) {
    return HomeworkDTO(
        subject: hw.subject,
        text: hw.text,
        deadline: hw.deadline,
        completion: hw.completion,
        priority: hw.priority,
        index: index);
  }

  HomeworkDTO getHomework(int index) {
    Homework hw = db.getHomework(index);
    return convertToDTO(hw, index);
  }

  // List<HomeworkDTO> getTodayHws(){
  //   for
  // }
}
