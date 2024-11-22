import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/data/settings_database.dart';
import 'package:school_manager/data/subjects_data/subject_dto_model.dart';
import 'package:school_manager/screens/subjects/widgets/new_subject_dialog.dart';
import 'package:school_manager/data/subjects_data/subject_model.dart';
import 'package:school_manager/screens/subjects/widgets/subject_tile.dart';
import 'package:school_manager/tasks_app.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  late List<SubjectDTO> subjectList = subjectService.getSortedList();

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
          SubjectDTO newSubject = await subjectService.addNewSubject(
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
    SubjectDTO subject = subjectService.getSubject(dbIndex);

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
            bakaId: subject.bakaId,
          );

          subjectService.editSubject(newSubject);
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
    SubjectDTO deletedSubject = subjectService.getSubject(dbIndex);
    subjectService.deleteSubject(deletedSubject.dbIndex);
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
            subjectService.revertLastlyDeletedSubject();
            if (mounted) {
              setState(() {
                subjectList = subjectService.getSortedList();
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
        actions: [
          if (settings.get(Setting.showDebugInfo))
            TextButton(
              onPressed: () {
                setState(() {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete all subjects?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            subjectService.deleteAllSubjects();
                            setState(() {
                              subjectList = subjectService.getSortedList();
                            });
                          },
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                });
              },
              child: const Text('Delete all'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new subject',
        onPressed: () {
          HapticFeedback.mediumImpact();
          createNewSubject();
        },
        child: const Icon(Icons.add),
      ),
      body: SlidableAutoCloseBehavior(
        child: Padding(
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
                  itemCount: subjectList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == subjectList.length) {
                      return const SizedBox(
                        height: 100,
                        key: Key('SubjectScreenSpacer'),
                      );
                    }
        
                    SubjectDTO subject = subjectList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      key: Key('$index'),
                      child: SubjectTile(
                        subject: subject,
                        onTap: () => editSubject(subject.dbIndex),
                        onDelete: () => deleteSubject(subject.dbIndex),
                      ),
                    );
                  },
                  onReorder: (int oldIndex, int newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final SubjectDTO item = subjectList.removeAt(oldIndex);
                    subjectService.changeSequence(oldIndex, newIndex);
                    setState(
                      () {
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
