import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/screens/subjects/widgets/new_subject_dialog.dart';
import 'package:school_manager/data/subjects_data/subject_database.dart';
import 'package:school_manager/data/subjects_data/subject_model.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final SubjectDatabase db = SubjectDatabase();
  late List<Subject> subjectList = db.getDatabase();

  TextEditingController nameController = TextEditingController();
  TextEditingController shortcutController = TextEditingController();

  @override
  void dispose() {
    db.updateDatabase();

    super.dispose();
  }

  void createNewSubject() {
    showDialog(
      context: context,
      builder: (context) => SubjectDialog(
        text: 'Add new subject',
        nameController: nameController,
        shortcutController: shortcutController,
        onSave: () {
          setState(
            () {
              db.addSubject(
                Subject(
                  name: nameController.text,
                  shortcut: shortcutController.text,
                ),
              );
            },
          );
        },
      ),
    ).then(
      (value) => {
        nameController.clear(),
        shortcutController.clear(),
      },
    );
  }

  void editSubject(int index) {
    nameController.text = subjectList[index].name;
    shortcutController.text = subjectList[index].shortcut;

    showDialog(
      context: context,
      builder: (context) => SubjectDialog(
        text: 'Edit subject',
        nameController: nameController,
        shortcutController: shortcutController,
        onSave: () {
          setState(
            () {
              db.saveEditedSubject(
                index,
                Subject(
                  name: nameController.text,
                  shortcut: shortcutController.text,
                ),
              );
            },
          );
        },
      ),
    ).then(
      (value) => {
        nameController.clear(),
        shortcutController.clear(),
      },
    );
  }

  void deleteSubject(int index) {
    setState(() {
      Subject deletedSubject = subjectList[index];
      db.deleteSubject(index);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Homework deleted'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () {
              if (mounted) {
                setState(() {
                  db.addSubject(deletedSubject);
                });
              }
            },
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          HapticFeedback.mediumImpact();
          createNewSubject();
        },
        child: const Icon(Icons.add),
      ),
      body: SlidableAutoCloseBehavior(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ReorderableListView(
            onReorderStart: (index) => HapticFeedback.lightImpact(),
            children: [
              for (int index = 0; index < subjectList.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  key: Key('$index'),
                  child: SubjectTile(
                    subject: subjectList[index],
                    onEdit: () => editSubject(index),
                    onDelete: () => deleteSubject(index),
                  ),
                )
            ],
            onReorder: (int oldIndex, int newIndex) {
              setState(
                () {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final Subject item = subjectList.removeAt(oldIndex);
                  subjectList.insert(newIndex, item);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
