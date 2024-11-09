import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/data/subjects_data/subject_dto_model.dart';
import 'package:school_manager/data/subjects_data/subject_service.dart';
import 'package:school_manager/data/table_data/timetable_database.dart';
import 'package:school_manager/extensions/color_extension.dart';
import 'package:school_manager/extensions/datetime_extension.dart';
import 'package:school_manager/widgets/cancel_save_button.dart';
import 'package:school_manager/data/priority_model.dart';

Future<void> showAddBottomSheet(
  BuildContext context, {
  String initialName = '',
  int initialPriority = 0,
  SubjectDTO? initialSubject,
  DateTime? initialDate,
  required void Function({
    required DateTime date,
    required int priority,
    required String text,
    SubjectDTO? subject,
  }) onSave,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    enableDrag: true,
    builder: (context) {
      return AddBottomSheet(
        initialSubject: initialSubject,
        initialPriority: initialPriority,
        initialName: initialName,
        initialDate: initialDate,
        onSave: onSave,
      );
    },
  );
  return;
}

class AddBottomSheet extends StatefulWidget {
  const AddBottomSheet({
    super.key,
    this.initialName = '',
    this.initialDate,
    this.initialPriority = 0,
    this.initialSubject,
    required this.onSave,
  });

  final void Function({
    required DateTime date,
    required int priority,
    required String text,
    SubjectDTO? subject,
  }) onSave;
  final String initialName;
  final DateTime? initialDate;
  final int initialPriority;
  final SubjectDTO? initialSubject;

  @override
  State<AddBottomSheet> createState() => _AddBottomSheetState();
}

class _AddBottomSheetState extends State<AddBottomSheet> {
  late final nameController = TextEditingController.fromValue(
      TextEditingValue(text: widget.initialName));
  late SubjectDTO? pickedSubject = widget.initialSubject;
  late DateTime pickedDate = widget.initialDate ?? DateTime.now();
  late int pickedPriority = widget.initialPriority;
  late final bool autoSetDate = widget.initialDate == null;

  final SubjectService _subjectService = SubjectService();
  late List<SubjectDTO> subjects = _subjectService.getSortedList();
  final _timetable = TimeTableDatabase().timeTable;

  late List<GlobalKey> keysList = List<GlobalKey>.generate(
    subjects.length,
    (index) => GlobalKey(),
  );

  void onSave() {
    widget.onSave(
      subject: pickedSubject,
      text: nameController.text,
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
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Container(
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        margin: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            CancelSaveButton(
              onSave: onSave,
            ),
            const SizedBox(height: 15),
            Wrap(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(subjects.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          key: keysList[index],
                          selected:
                              pickedSubject?.dbIndex == subjects[index].dbIndex,
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
              ],
            ),
            const SizedBox(height: 10),
            Autocomplete<SubjectDTO>(
              fieldViewBuilder: (context, textEditingController, focusNode,
                  onFieldSubmitted) {
                return TextField(
                  controller: nameController,
                  focusNode: focusNode,
                  autofocus: true,
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
                // setState(() {
                //   pickedSubject = subject;
                //   pickedDate =
                //       _timetable.nextDateForSubject(subject) ?? pickedDate;
                // });
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
                  Priority priority = Priority(index, context);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: index == pickedPriority,
                      label: Text(
                        priority.name,
                        style: TextStyle(
                          color: priority.color.dynamicLighten(
                              makeItLighter: isDark, amount: 0.5),
                        ),
                      ),
                      backgroundColor: priority.color
                          .dynamicLighten(makeItLighter: !isDark, amount: 0.37),
                      selectedColor: priority.color
                          .dynamicLighten(makeItLighter: !isDark, amount: 0.23),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: priority.color,
                        ),
                      ),
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
          ],
        ),
      ),
    );
  }
}
