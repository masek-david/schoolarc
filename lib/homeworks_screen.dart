import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:school_manager/data/database.dart';
import 'package:school_manager/util/homework_tile.dart';
import 'package:school_manager/util/hw_create_bottom_sheet.dart';

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen> {
  // reference hive box
  final _myBox = Hive.box('myBox');
  HomeworksDatabase db = HomeworksDatabase();

  @override
  void initState() {
    // if first time ever opening app, default data
    if (_myBox.get("HOMEWORKS") == null) {
      db.createInitialData();
    } else {
      // there already exist data
      db.loadData();
    }

    super.initState();
  }

  // text controller
  var _subjectController = TextEditingController();
  var _nameController = TextEditingController();

  void checkBoxChange(bool? value, int index) {
    setState(() {
      db.hwList[index][3] = !db.hwList[index][3];
    });
    db.updateDatabase();
  }

  void sortHwList() {
    db.hwList.sort((b, a) => a[4].compareTo(b[4]));
  }

  void deleteTask(int index) {
    setState(() {
      db.hwList.removeAt(index);
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
      db.hwList.add([
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
          itemCount: db.hwList.length,
          itemBuilder: (context, index) {
            return HomeworkTile(
              hwSubject: db.hwList[index][0],
              hwText: db.hwList[index][1],
              hwDeadline: db.hwList[index][2],
              hwCompletion: db.hwList[index][3],
              hwPriority: db.hwList[index][4],
              onChangedCompletion: (value) => checkBoxChange(value, index),
              onDelete: (context) => deleteTask(index),
              onEdit: () => editHW(index),
            );
          },
        ),
      ),
    );
  }
}
