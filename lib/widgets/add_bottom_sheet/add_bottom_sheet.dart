import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/models/subjects/subject_model.dart';
import 'package:school_manager/models/task_model.dart';
import 'package:school_manager/provider/subject_notifier.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/screens/timetable/select_subject.dart';
import 'package:school_manager/widgets/cancel_save_button.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/widgets/priority_picker_new.dart';

class AddTaskBottomSheet extends ConsumerStatefulWidget {
  const AddTaskBottomSheet({
    super.key,
    required this.initialTask,

    /// if true, when a subject is selected the date will be set to first appearance of this subject in constant timetable
    required this.autoSetDate,
  });

  final Task initialTask;
  final bool autoSetDate;

  @override
  ConsumerState<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends ConsumerState<AddTaskBottomSheet> {
  late final nameController = TextEditingController.fromValue(
      TextEditingValue(text: widget.initialTask.text));
  late final descriptionController = TextEditingController.fromValue(
      TextEditingValue(text: widget.initialTask.description ?? ''));
  late Subject? pickedSubject = widget.initialTask.subject;
  late DateTime pickedDate = widget.initialTask.deadline;
  late int pickedPriority = widget.initialTask.priority.index;

  late List<Subject> subjects = ref.read(subjectsSortedProvider);
  final _timetable = timetableDb.timeTable;

  late List<GlobalKey> keysList = List<GlobalKey>.generate(
    subjects.length,
    (index) => GlobalKey(),
  );

  void onSave() {
    Navigator.pop(
      context,
      widget.initialTask.copyWith(
        subject: pickedSubject,
        text: nameController.text,
        description: descriptionController.text,
        deadline: pickedDate,
        priority: TaskPriority(pickedPriority),
        timestamp: DateTime.now().toUtc(),
      ),
    );
  }

  void setSubject(Subject? subject) {
    setState(() {
      pickedSubject = subject;
      if (widget.autoSetDate && subject != null) {
        pickedDate = _timetable.nextDateForSubject(subject) ?? pickedDate;
      }
    });
    if (subject != null) {
      Scrollable.ensureVisible(
          keysList[subjects.indexOf(subject)].currentContext!,
          duration: const Duration(milliseconds: 500));
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pickedSubject != null) {
        Scrollable.ensureVisible(
          keysList[subjects.indexWhere(
            (element) => pickedSubject!.id == element.id,
          )]
              .currentContext!,
          duration: const Duration(milliseconds: 500),
        );
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 12),
              CancelSaveButton(onSave: onSave),
              const SizedBox(height: 15),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      final newSubject = await showDialog(
                        context: context,
                        builder: (context) => SelectSubjectDialog(
                          subjects: subjects,
                          showAllSubjects: false,
                        ),
                      );

                      setSubject(newSubject);
                    },
                    icon: const Icon(Icons.search),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        // cant use .map(), i need the index
                        children: List.generate(subjects.length, (index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              key: keysList[index],
                              selected: pickedSubject?.id == subjects[index].id,
                              label: Text(subjects[index].name),
                              onSelected: (value) {
                                if (!value) {
                                  setSubject(null);
                                } else {
                                  setSubject(subjects[index]);
                                }
                              },
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Autocomplete<Subject>(
                fieldViewBuilder: (context, textEditingController, focusNode,
                    onFieldSubmitted) {
                  return TextField(
                    controller: nameController,
                    focusNode: focusNode,
                    autofocus: true,
                    maxLines: null,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      if (pickedSubject == null) {
                        onFieldSubmitted();
                      }
                      if (nameController.text.isNotEmpty) {
                        onSave();
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
                  nameController.text = '';
                  setSubject(subject);
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
                      return subject.containsText(textEditingValue.text);
                    },
                  );
                },
              ),
              SizedBox(height: 8),
              SizedBox(
                // listview musi mit vysku, kterou urci sizedbox
                height: 40,
                child: PriorityPickerNew(
                  selectedPriority: pickedPriority,
                  onSelected: (value) => setState(() {
                    pickedPriority = value;
                  }),
                ),
              ),
              // SizedBox(
              //   // listview musi mit vysku, kterou urci sizedbox
              //   height: 40,
              //   child: PriorityPicker(
              //     pickedPriority: pickedPriority,
              //     onSelected: (value) => setState(() {
              //       pickedPriority = value;
              //     }),
              //   ),
              // ),
              const Divider(),
              InkWell(
                onTap: () async {
                  DateTime? newDate = await showDatePicker(
                    context: context,
                    locale: const Locale('en', 'GB'),
                    initialDate: pickedDate,
                    firstDate: DateTime.utc(0),
                    lastDate: DateTime.utc(3000),
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
                        pickedDate.formattedDate(),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Today'),
                    selected: pickedDate.isSameDay(DateTime.now()),
                    onSelected: (value) {
                      DateTime now = DateTime.now();
                      setState(() {
                        pickedDate = DateTime(now.year, now.month, now.day);
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Tomorrow'),
                    selected: pickedDate
                        .isSameDay(DateTime.now().add(const Duration(days: 1))),
                    onSelected: (value) {
                      DateTime now = DateTime.now();
                      setState(() {
                        pickedDate = DateTime(now.year, now.month, now.day)
                            .add(const Duration(days: 1));
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(
                        'Next ${DateFormat('EEEE').format(DateTime.now()).toLowerCase()}'),
                    selected: pickedDate
                        .isSameDay(DateTime.now().add(const Duration(days: 7))),
                    onSelected: (value) {
                      DateTime now = DateTime.now();
                      setState(() {
                        pickedDate = DateTime(now.year, now.month, now.day)
                            .add(const Duration(days: 7));
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: null,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.all(15),
                  border: OutlineInputBorder(),
                  hintText: 'Description',
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
