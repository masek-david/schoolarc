import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/data/subjects_data/subject_dto_model.dart';
import 'package:school_manager/data/subjects_data/subject_service.dart';
import 'package:school_manager/extensions/string_extension.dart';
import 'package:school_manager/widgets/cancel_save_button.dart';
import 'package:school_manager/data/priority_model.dart';

class HwBottomSheet extends StatefulWidget {
  const HwBottomSheet({
    super.key,
    required this.nameController,
    required this.initialDate,
    required this.initialPriority,
    required this.onSave,
    required this.initialCompletion,
    required this.index,
  });

  final TextEditingController nameController;
  final void Function({
    required DateTime date,
    required int priority,
    required int index,
    required String text,
    required String subject,
    required bool completion,
    required dynamic context,
  }) onSave;
  final DateTime initialDate;
  final int initialPriority;
  final bool initialCompletion;
  final int index;

  @override
  State<HwBottomSheet> createState() => _HwBottomSheetState();
}

class _HwBottomSheetState extends State<HwBottomSheet> {
  late DateTime pickedDate = widget.initialDate;
  late int pickedPriority = widget.initialPriority;
  final SubjectService _subjectService = SubjectService();
  late List<SubjectDTO> subjects = _subjectService.getSortedList();
  SubjectDTO? pickedSubject;

  late List<GlobalKey> keysList = List<GlobalKey>.generate(
    subjects.length,
    (index) => GlobalKey(),
  );

  void onSave() {
    widget.onSave(
      subject: pickedSubject?.shortcut ?? '',
      text: widget.nameController.text,
      context: context,
      date: pickedDate,
      priority: pickedPriority,
      completion: widget.initialCompletion,
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
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: keysList[index],
                      selected: pickedSubject == subjects[index],
                      label: Text(subjects[index].name),
                      onSelected: (value) {
                        setState(
                          () {
                            if (!value) {
                              pickedSubject = null;
                            } else {
                              pickedSubject = subjects[index];
                            }
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Autocomplete<SubjectDTO>(
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextField(
                  controller: widget.nameController,
                  focusNode: focusNode,
                  autofocus: true,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    if (pickedSubject == null) {
                      onFieldSubmitted();
                    }
                    if (widget.nameController.text.isNotEmpty) {
                      onSave();
                      Navigator.pop(context);
                    }
                  },
                  onChanged: (value) {
                    textEditingController.text = value;
                  },
                  onEditingComplete: () {},
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(15),
                    border: OutlineInputBorder(),
                  ),
                );
              },
              onSelected: (subject) {
                setState(() {
                  pickedSubject = subject;
                  widget.nameController.text = '';
                });
                Scrollable.ensureVisible(
                    keysList[subjects.indexOf(subject)].currentContext!,
                    duration: const Duration(milliseconds: 500));
              },
              displayStringForOption: (subject) {
                return subject.name;
              },
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text == '' || pickedSubject != null) {
                  return const Iterable.empty();
                }
                return subjects.where(
                  (subject) {
                    return subject.name.withoutDiacriticalMarks
                            .toLowerCase()
                            .contains(textEditingValue
                                .text.withoutDiacriticalMarks
                                .toLowerCase()) ||
                        subject.shortcut.withoutDiacriticalMarks
                            .toLowerCase()
                            .contains(textEditingValue
                                .text.withoutDiacriticalMarks
                                .toLowerCase());
                  },
                );
              },
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
                      backgroundColor: priority.color.withAlpha(25),
                      selectedColor: priority.color.withAlpha(100),
                      onSelected: (value) => setState(
                        () {
                          pickedPriority = index;
                        },
                      ),
                    ),
                  );
                },
              ),
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
