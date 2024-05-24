import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/data/database.dart';
import 'package:school_manager/util/homework_tile.dart';
import 'package:school_manager/util/hw_create_bottom_sheet.dart';
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
  Map<int, List<Homework>> sortedHw = {
    0: <Homework>[],
    1: <Homework>[],
    2: <Homework>[],
    3: <Homework>[],
  };

  @override
  void initState() {
    // if first time ever opening app, default data
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

  void checkBoxChange(bool? value, int index) {
    setState(() {
      db.changeCompletion(index);
    });
  }

  void cleanSortedHwList() {
    for (int i = 0; i <= 3; i++) {
      sortedHw[i]!.clear();
    }
  }

  void sortHwList() {
    List hwList = db.getDatabase();
    cleanSortedHwList();
    for (Homework hw in hwList) {
      var list = sortedHw[
          hw.priority]; // var list je odkaz na list Homework v mape sortedHw
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
    db.updateDatabase();
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
          hwIndex: 0, // index neni potreba u zakladani noveho listu
        );
      },
    ).then(
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
      Homework newHomework = Homework(
        subject: _subjectController.text,
        text: _nameController.text,
        deadline: date,
        completion: false,
        priority: priority,
      );
      db.addHw(newHomework);
      sortedHw[newHomework.priority]!.add(newHomework);
      _nameController.clear();
      _subjectController.clear();
      // sortHwList();
    });
    Navigator.of(context).pop();
    // db.updateDatabase();
  }

  void editHW(int index) {
    _nameController = TextEditingController(text: db.hwList[index][1]);
    _subjectController = TextEditingController(text: db.hwList[index][0]);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      builder: (context) {
        return HwBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          initialDate: db.hwList[index][2],
          initialPriority: db.hwList[index][4],
          hwIndex: index,
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
      db.hwList[index] = ([
        _subjectController.text,
        _nameController.text,
        date,
        false,
        priority
      ]);
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
          itemBuilder: (context, priorityIndex) {
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
                  itemBuilder: (context, hwIndex) {
                    if (sortedHw[priorityIndex] != null &&
                        sortedHw[priorityIndex]!.isEmpty) {
                      return null;
                    }
                    Homework hw = sortedHw[priorityIndex]![hwIndex];
                    return HomeworkTile(
                      hwText: hw.text,
                      hwDeadline: hw.deadline,
                      hwSubject: hw.subject,
                      hwCompletion: hw.completion,
                      hwPriority: hw.priority,
                      onChangedCompletion: (value) =>
                          checkBoxChange(value, hwIndex),
                      onDelete: (context) => deleteTask(hwIndex),
                      onEdit: () => editHW(hwIndex),
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
