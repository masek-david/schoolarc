import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/data/database.dart';
import 'package:school_manager/util/homework_tile.dart';
import 'package:school_manager/util/hw_create_bottom_sheet.dart';
import 'package:school_manager/data/hw_dto_model.dart';
import 'package:school_manager/data/hw_model.dart';

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen> {
  // reference hive box
  final _myBox = Hive.box('myBox');
  HomeworksDatabase db = HomeworksDatabase();
  Map<int, List<HomeworkDTO>> sortedHw = {
    0: <HomeworkDTO>[],
    1: <HomeworkDTO>[],
    2: <HomeworkDTO>[],
    3: <HomeworkDTO>[],
  };

  @override
  void initState() {
    // if first time ever opening app, default data
    // _myBox.clear();
    // db.createInitialData();
    // db.updateDatabase();
    if (_myBox.get("HOMEWORKS") == null) {
      db.createInitialData();
    } else {
      // there already exist data
      db.loadData();
    }

    sortHwList();
    super.initState();
  }

  // text controller
  var _subjectController = TextEditingController();
  var _nameController = TextEditingController();

  void checkBoxChange(int index) {
    setState(() {
      db.changeCompletion(index);
      sortHwList();
    });
  }

  void cleanSortedHwList() {
    for (int i = 0; i <= 3; i++) {
      sortedHw[i]!.clear();
    }
  }

  void sortHwList() {
    List<HomeworkDTO> hwList = db.getDatabase();
    cleanSortedHwList();
    for (HomeworkDTO hw in hwList) {
      var list = sortedHw[
          // var list je odkaz na list Homework v mape sortedHw => priradi se do mapy se spravnou prioritou
          hw.priority];
      if (list != null) {
        list.add(hw);
      }
    }
  }

  void deleteTask(int index) {
    setState(() {
      db.deleteHw(index);
      sortHwList();
    });
  }

  void createNewHW() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return HwBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: DateTime.now(),
          initialPriority: 0,
          onSave: saveNewHW,
          index: 0, // index neni potreba u zakladani noveho listu
        );
      },
    ).then(
      // po zavreni bottomSheetu se smaze uzivatelem zadany text
      (value) => {
        _nameController.clear(),
        _subjectController.clear(),
      },
    );
  }

  void saveNewHW(
      {required DateTime date, required int priority, required int index}) {
    // index se tady nepouziva, ale je potreba u editHW
    setState(() {
      HomeworkDTO newHomework = db.addHw(Homework(
        subject: _subjectController.text,
        text: _nameController.text,
        deadline: date,
        completion: false,
        priority: priority,
      ));
      sortedHw[newHomework.priority]!.add(newHomework);
      _nameController.clear();
      _subjectController.clear();
    });
    Navigator.of(context).pop();
  }

  void editHW(int index) {
    HomeworkDTO currentlyEditedTask = db.getHomework(index);
    _nameController = TextEditingController(text: currentlyEditedTask.text);
    _subjectController =
        TextEditingController(text: currentlyEditedTask.subject);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return HwBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: currentlyEditedTask.deadline,
          initialPriority: currentlyEditedTask.priority,
          index: index,
          onSave: saveEditedHW,
        );
      },
    ).then(
      (value) => {
        _nameController.clear(),
        _subjectController.clear(),
      },
    );
  }

  void saveEditedHW(
      {required DateTime date, required int priority, required int index}) {
    setState(() {
      db.editHW(
          index,
          Homework(
              subject: _subjectController.text,
              text: _nameController.text,
              deadline: date,
              completion: false,
              priority: priority));
      _nameController.clear();
      _subjectController.clear();
      sortHwList();
    });
    Navigator.of(context).pop();
    db.updateDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHW,
        child: const Icon(Icons.add),
      ),
      body: SlidableAutoCloseBehavior(
        child: ListView.builder(
          itemCount: 4,
          itemBuilder: (context, index) {
            final priorityIndex = 4 - 1 - index; // obrati index
            // return PriorityList(
            //   priorityIndex: priorityIndex,
            //   hwWithPriority: sortedHw[priorityIndex],
            //   checkBoxChange: (context) => checkBoxChange(index),
            //   deleteTask: (context) => deleteTask(index),
            //   editHW: (context) => editHW(index),
            // );
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Priority:'),
                      Text(priorityIndex.toString()),
                    ],
                  ),
                ),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: sortedHw[priorityIndex]!.length,
                  itemBuilder: (context, indexInSortedList) {
                    if (sortedHw[priorityIndex] != null &&
                        sortedHw[priorityIndex]!.isEmpty) {
                      return null;
                    }
                    HomeworkDTO hw =
                        sortedHw[priorityIndex]![indexInSortedList];
                    return HomeworkTile(
                      hwText: hw.text,
                      hwDeadline: hw.deadline,
                      hwSubject: hw.subject,
                      hwCompletion: hw.completion,
                      hwPriority: hw.priority,
                      onChangedCompletion: (value) => checkBoxChange(hw.index),
                      onDelete: (context) => deleteTask(hw.index),
                      onEdit: () => editHW(hw.index),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
