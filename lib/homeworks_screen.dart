import 'package:flutter/material.dart';
import 'package:school_manager/util/homework_tile.dart';
import 'package:school_manager/util/hw_create_bottom_sheet.dart';

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworkSscreenState();
}

class _HomeworkSscreenState extends State<HomeworksScreen> {
  // text controller
  final _subjectController = TextEditingController();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();

  List hwList = [
    ["Cj", "ps 12/5", "14.5.", false],
    ["Ma", "uc 23/34", "13.5.", true],
    ["Ma", "uc 23/34", "13.5.", false],
  ];

  void checkBoxChange(bool? value, int index) {
    setState(() {
      hwList[index][3] = !hwList[index][3];
    });
  }

  void deleteTask(int index) {
    setState(() {
      hwList.removeAt(index);
    });
  }

  void createNewHW() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return HwBottomSheet(
          subjectController: _subjectController,
          nameController: _nameController,
          dateController: _dateController,
          onSave: saveNewHW,
        );
      },
    );
  }

  void saveNewHW() {
    setState(() {
      hwList.add([_subjectController.text, _nameController.text, '99', false]);
      _nameController.clear();
      _subjectController.clear();
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: createNewHW,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
          itemCount: hwList.length,
          itemBuilder: (context, index) {
            return HomeworkTile(
              hwText: hwList[index][1],
              hwDeadline: hwList[index][2],
              hwSubject: hwList[index][0],
              completion: hwList[index][3],
              onChanged: (value) => checkBoxChange(value, index),
              deleteFunction: (context) => deleteTask(index),
            );
          }),
    );
  }
}
