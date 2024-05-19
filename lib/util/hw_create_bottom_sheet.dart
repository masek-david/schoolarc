import 'package:flutter/material.dart';

class HwBottomSheet extends StatefulWidget {
  const HwBottomSheet({
    super.key,
    required this.subjectController,
    required this.nameController,
    required this.onSave,
  });

  final TextEditingController subjectController;
  final TextEditingController nameController;
  final void Function({required DateTime date}) onSave;

  @override
  State<HwBottomSheet> createState() => _HwBottomSheetState();
}

class _HwBottomSheetState extends State<HwBottomSheet> {
  DateTime pickedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
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
                    widget.onSave(date: pickedDate);
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
                hintText: 'Name',
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
            // const Row(
            //   children: [
            //     ChoiceChip(label: Text('Homework'), selected: false),
            //     Chip(
            //       label: Text('Homework'),

            //     ),
            //     SizedBox(
            //       width: 10,
            //     ),
            //     Chip(label: Text('Test')),
            //   ],
            // ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Deadline:', ),
                Text('${pickedDate.day}.${pickedDate.month}.${pickedDate.year}'),
              ], // '${hwList[index][2].day}.${hwList[index][2].month}.'
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
                      lastDate: DateTime.utc(2040),
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
                      pickedDate = DateTime.now().add(const Duration(days: 1));
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
