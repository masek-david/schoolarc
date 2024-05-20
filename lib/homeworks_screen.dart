import 'package:flutter/material.dart';
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
  final _subjectController = TextEditingController();
  final _nameController = TextEditingController();
  final _priorityController = TextEditingController();

  void checkBoxChange(bool? value, int index) {
    setState(() {
      db.hwList[index][3] = !db.hwList[index][3];
    });
    db.updateDatabase();
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
      builder: (context) {
        return HwBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          priorityController: _priorityController,
          onSave: saveNewHW,
        );
      },
    );
  }

  void saveNewHW({required DateTime date}) {
    setState(() {
      db.hwList.add([
        _subjectController.text,
        _nameController.text,
        date,
        false,
        _priorityController.text
      ]);
      _nameController.clear();
      _subjectController.clear();
      _priorityController.clear();
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
      body: ListView.builder(
          itemCount: db.hwList.length,
          itemBuilder: (context, index) {
            return HomeworkTile(
              hwText: db.hwList[index][1],
              hwDeadline:
                  '${db.hwList[index][2].day}.${db.hwList[index][2].month}.',
              hwSubject: db.hwList[index][0],
              completion: db.hwList[index][3],
              hwPriority: int.parse(db.hwList[index][4]),
              onChanged: (value) => checkBoxChange(value, index),
              onDeleteFunction: (context) => deleteTask(index),
            );
          }),
    );
  }
}
