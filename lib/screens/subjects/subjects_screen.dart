import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/data/subjects_data/subject_dto_model.dart';
import 'package:school_manager/data/subjects_data/subject_service.dart';
import 'package:school_manager/screens/subjects/widgets/new_subject_dialog.dart';
import 'package:school_manager/data/subjects_data/subject_model.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final SubjectService _service = SubjectService();
  late List<SubjectDTO> subjectList = _service.getSortedList();

  TextEditingController nameController = TextEditingController();
  TextEditingController shortcutController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    shortcutController.dispose();

    super.dispose();
  }

  void createNewSubject() {
    showDialog(
      context: context,
      builder: (context) => SubjectDialog(
        text: 'Add new subject',
        nameController: nameController,
        shortcutController: shortcutController,
        onSave: () async {
          SubjectDTO newSubject = await _service.addNewSubject(
            Subject(
              name: nameController.text,
              shortcut: shortcutController.text,
            ),
          );
          setState(
            () {
              subjectList.add(newSubject);
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

  void editSubject(int dbIndex) {
    SubjectDTO subject = _service.getSubject(dbIndex);

    nameController.text = subject.name;
    shortcutController.text = subject.shortcut;

    showDialog(
      context: context,
      builder: (context) => SubjectDialog(
        text: 'Edit subject',
        nameController: nameController,
        shortcutController: shortcutController,
        onSave: () {
          SubjectDTO newSubject = SubjectDTO(
            name: nameController.text,
            shortcut: shortcutController.text,
            dbIndex: subject.dbIndex,
          );

          _service.editSubject(newSubject);
          setState(
            () {
              subjectList[subjectList.indexWhere(
                (element) {
                  return element.dbIndex == newSubject.dbIndex;
                },
              )] = newSubject;
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

  void deleteSubject(int dbIndex) {
    SubjectDTO deletedSubject = _service.getSubject(dbIndex);
    _service.deleteSubject(deletedSubject.dbIndex);
    setState(() {
      subjectList.removeWhere(
        (element) {
          return element.dbIndex == deletedSubject.dbIndex;
        },
      );
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Homework deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            _service.revertLastlyDeletedSubject();
            if (mounted) {
              setState(() {
                subjectList = _service.getSortedList();
              });
            }
          },
        ),
      ),
    );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new subject',
        onPressed: () {
          HapticFeedback.mediumImpact();
          createNewSubject();
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: subjectList.isEmpty
            ? const Center(
              child: Text(
                  'No subjects found. You can create new subjects by tapping the plus button.',
                  textAlign: TextAlign.center,
                ),
            )
            : ReorderableListView.builder(
                onReorderStart: (index) => HapticFeedback.lightImpact(),
                itemCount: subjectList.length,
                itemBuilder: (context, index) {
                  SubjectDTO subject = subjectList[index];
      
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    key: Key('$index'),
                    child: SubjectTile(
                      subject: subject,
                      onEdit: () => editSubject(subject.dbIndex),
                      onDelete: () => deleteSubject(subject.dbIndex),
                    ),
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final SubjectDTO item = subjectList.removeAt(oldIndex);
                  _service.changeSequence(oldIndex, newIndex);
                  setState(
                    () {
                      subjectList.insert(newIndex, item);
                    },
                  );
                },
              ),
      ),
    );
  }
}
