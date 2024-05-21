import 'package:flutter/material.dart';
import 'package:school_manager/util/get_priority_color.dart';

class HwBottomSheet extends StatefulWidget {
  const HwBottomSheet({
    super.key,
    required this.subjectController,
    required this.nameController,
    required this.onSave,
  });

  final TextEditingController subjectController;
  final TextEditingController nameController;
  final void Function({required DateTime date, required int priority}) onSave;

  @override
  State<HwBottomSheet> createState() => _HwBottomSheetState();
}

class _HwBottomSheetState extends State<HwBottomSheet> {
  DateTime pickedDate = DateTime.now();
  int pickedPriority = 0;

  @override
  Widget build(BuildContext context) {
    const List<String> prioritiesList = [
      'No priority',
      'Low',
      'Medium',
      'High'
    ];

    return BottomSheet(
      enableDrag: true,
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
                    widget.onSave(date: pickedDate, priority: pickedPriority);
                  },
                  child: const Text('Save'),
                )
              ],
            ),
            const SizedBox(height: 15),
            TextField(
              controller: widget.nameController,
              autofocus: true,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(15),
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Assignment',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: widget.subjectController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(15),
                filled: true,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(10),
                ),
                hintText: 'Subject',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Deadline:',
                ),
                Text(
                    '${pickedDate.day}.${pickedDate.month}.${pickedDate.year}'),
              ],
            ),
            Row(
              children: [
                OutlinedButton(
                  child: const Text('Choose date'),
                  onPressed: () async {
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
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      pickedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).add(const Duration(days: 1));
                    });
                  },
                  child: const Text('Tommorow'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
