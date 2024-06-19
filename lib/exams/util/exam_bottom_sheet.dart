import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/subjects/subject_database.dart';
import 'package:school_manager/subjects/subject_model.dart';
import 'package:school_manager/util/cancel_save_button.dart';
import 'package:school_manager/util/priority_model.dart';

class ExamBottomSheet extends StatefulWidget {
  const ExamBottomSheet(
      {super.key,
      required this.subjectController,
      required this.nameController,
      required this.initialDate,
      required this.onSave,
      required this.initialPriority,
      required this.index});

  final TextEditingController subjectController;
  final TextEditingController nameController;
  final void Function({
    required DateTime date,
    required int priority,
    required int index,
    required String text,
    required String subject,
    required dynamic context,
  }) onSave;
  final DateTime initialDate;
  final int initialPriority;
  final int index;

  @override
  State<ExamBottomSheet> createState() => _ExamBottomSheetState();
}

class _ExamBottomSheetState extends State<ExamBottomSheet> {
  DateTime pickedDate = DateTime.now();
  int pickedPriority = 0;
  int? pickedSubject;
  SubjectDatabase subjectDatabase = SubjectDatabase();
  List<Subject> subjects = [];

  @override
  void initState() {
    super.initState();

    pickedDate = widget.initialDate;
    pickedPriority = widget.initialPriority;

    subjectDatabase.initiate();
    subjects = subjectDatabase.getDatabase();
  }

  void onSave() {
    widget.onSave(
      subject: widget.subjectController.text,
      text: widget.nameController.text,
      context: context,
      date: pickedDate,
      priority: pickedPriority,
      index: widget.index,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      enableDrag: false,
      onClosing: () {},
      builder: (context) => Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        margin: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CancelSaveButton(onSave: onSave),
            const SizedBox(height: 15),
            TextField(
              controller: widget.nameController,
              autofocus: true,
              maxLines: null,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(),
                labelText: 'Assignment',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: widget.subjectController,
              maxLength: 5,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(),
                labelText: 'Subject',
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: index == pickedSubject,
                      label: Text(subjects[index].name),
                      onSelected: (value) {
                        setState(
                          () {
                            if (!value) {
                              pickedSubject = null;
                              widget.subjectController.text = '';
                            } else {
                              pickedSubject = index;
                              widget.subjectController.text =
                                  subjects[index].shortcut;
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            SizedBox(
              // listview musi mit vysku, kterou urci sizedbox
              height: 40,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    Priority priority = Priority(index, context);
                    return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          selected: index == pickedPriority,
                          label: Text(priority.name),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: priority.color,
                            ),
                          ),
                          backgroundColor: priority.color.withOpacity(0.10),
                          selectedColor: priority.color.withOpacity(0.45),
                          onSelected: (value) => setState(() {
                            pickedPriority = index;
                          }),
                        ));
                  }),
            ),
            const Divider(),
            InkWell(
              onTap: () async {
                DateTime? newDate = await showDatePicker(
                  context: context,
                  locale: const Locale('en', 'GB'),
                  initialDate: pickedDate,
                  firstDate: DateTime.utc(2000),
                  lastDate: DateTime.utc(2100),
                );

                if (newDate == null) return;

                setState(() {
                  pickedDate = newDate;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 15, bottom: 15, left: 5, right: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Deadline:',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      // pickedDate.toString(),
                      '${pickedDate.day}.${pickedDate.month}.${pickedDate.year}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                ActionChip(
                  label: const Text('Today'),
                  onPressed: () {
                    setState(() {
                      pickedDate = DateTime(DateTime.now().year,
                          DateTime.now().month, DateTime.now().day);
                    });
                  },
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Tomorrow'),
                  onPressed: () {
                    setState(() {
                      pickedDate = DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day)
                          .add(const Duration(days: 1));
                    });
                  },
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: Text(
                      'Next ${DateFormat('EEEE').format(DateTime.now()).toLowerCase()}'),
                  onPressed: () {
                    setState(() {
                      pickedDate = DateTime(DateTime.now().year,
                              DateTime.now().month, DateTime.now().day)
                          .add(const Duration(days: 7));
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
