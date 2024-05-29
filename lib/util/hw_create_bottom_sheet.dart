import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/util/get_priority_color.dart';

class HwBottomSheet extends StatefulWidget {
  const HwBottomSheet(
      {super.key,
      required this.subjectController,
      required this.nameController,
      required this.initialDate,
      required this.initialPriority,
      required this.onSave,
      required this.initialCompletion,
      required this.index});

  final TextEditingController subjectController;
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
  DateTime pickedDate = DateTime.now();
  int pickedPriority = 0;

  @override
  void initState() {
    pickedDate = widget.initialDate;
    pickedPriority = widget.initialPriority;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const List<String> prioritiesList = [
      'No priority',
      'Low',
      'Medium',
      'High'
    ];

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    widget.onSave(
                      subject: widget.subjectController.text,
                      text: widget.nameController.text,
                      context: context,
                      date: pickedDate,
                      priority: pickedPriority,
                      completion: widget.initialCompletion,
                      index: widget.index,
                    );
                  },
                  child: const Text('Save'),
                )
              ],
            ),
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
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.all(15),
                border: OutlineInputBorder(),
                labelText: 'Subject',
              ),
            ),
            const Divider(),
            SizedBox(
              // listview musi mit vysku, kterou urci sizedbox
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(prioritiesList[index]),
                    selected: index == pickedPriority,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color:
                            getPriorityColor(priority: index, context: context),
                      ),
                    ),
                    backgroundColor:
                        getPriorityColor(priority: index, context: context)
                            .withOpacity(0.10),
                    selectedColor:
                        getPriorityColor(priority: index, context: context)
                            .withOpacity(0.45),
                    onSelected: (value) => setState(() {
                      pickedPriority = index;
                    }),
                  ),
                ),
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
                padding: const EdgeInsets.all(8.0),
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
