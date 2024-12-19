import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/models/subjects/subject_dto_model.dart';
import 'package:school_manager/services/timetable_database.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/screens/timetable/select_subject.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/cancel_save_button.dart';
import 'package:school_manager/models/priority_model.dart';

class AddTaskBottomSheet extends StatefulWidget {
  const AddTaskBottomSheet({
    super.key,
    this.initialName = '',
    this.initialDate,
    this.initialPriority = 0,
    this.initialSubject,
    this.initialDescription,
    required this.onSave,
  });

  final void Function({
    required DateTime date,
    required int priority,
    required String text,
    required String? description,
    SubjectDTO? subject,
  }) onSave;
  final String initialName;
  final DateTime? initialDate;
  final int initialPriority;
  final SubjectDTO? initialSubject;
  final String? initialDescription;

  @override
  State<AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  late final nameController = TextEditingController.fromValue(
      TextEditingValue(text: widget.initialName));
  late final descriptionController = TextEditingController.fromValue(
      TextEditingValue(text: widget.initialDescription ?? ''));
  late SubjectDTO? pickedSubject = widget.initialSubject;
  late DateTime pickedDate = widget.initialDate ?? DateTime.now();
  late int pickedPriority = widget.initialPriority;
  late final bool autoSetDate = widget.initialDate == null;

  late List<SubjectDTO> subjects = subjectService.getSortedList();
  final _timetable = TimeTableDatabase().timeTable;

  late List<GlobalKey> keysList = List<GlobalKey>.generate(
    subjects.length,
    (index) => GlobalKey(),
  );

  void onSave() {
    widget.onSave(
      subject: pickedSubject,
      text: nameController.text,
      description: descriptionController.text,
      date: pickedDate,
      priority: pickedPriority,
    );
  }

  void setSubject(SubjectDTO? subject) {
    setState(() {
      pickedSubject = subject;
      if (autoSetDate && subject != null) {
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
            (element) => pickedSubject!.dbIndex == element.dbIndex,
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

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    // final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
            margin: const EdgeInsets.all(15),
            child: SingleChildScrollView(
              // controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CancelSaveButton(
                    onSave: onSave,
                  ),
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
                                  selected: pickedSubject?.dbIndex ==
                                      subjects[index].dbIndex,
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
                  Autocomplete<SubjectDTO>(
                    fieldViewBuilder: (context, textEditingController,
                        focusNode, onFieldSubmitted) {
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
                      nameController.text = '';
                      setSubject(subject);
                    },
                    displayStringForOption: (subject) {
                      return subject.name;
                    },
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text == '' ||
                          pickedSubject != null) {
                        return const Iterable.empty();
                      }
                      return subjects.where(
                        (subject) {
                          return subject.containsText(textEditingValue.text);
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
                        bool isSelected = index == pickedPriority;
                        TaskPriority priority = TaskPriority(index);
                        final scheme = ColorScheme.fromSeed(
                          seedColor: priority.getColor(context),
                          brightness: brightness,
                          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
                        );

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            selected: isSelected,
                            onSelected: (value) => setState(
                              () => pickedPriority = index,
                            ),
                            selectedColor: scheme.primaryContainer,
                            backgroundColor: scheme.surfaceContainer,
                            checkmarkColor: scheme.onPrimaryContainer,
                            label: Text(
                              priority.name,
                              style: TextStyle(
                                color: isSelected
                                    ? scheme.onPrimaryContainer
                                    : scheme.primary,
                              ),
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
                            '${pickedDate.day}.${pickedDate.month}.${pickedDate.year}',
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
                        selected: pickedDate.isSameDay(
                            DateTime.now().add(const Duration(days: 1))),
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
                        selected: pickedDate.isSameDay(
                            DateTime.now().add(const Duration(days: 7))),
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
                ],
              ),
            ),
          )
    );
  }
}
