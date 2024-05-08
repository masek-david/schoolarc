import 'package:flutter/material.dart';
// import 'package:school_manager/homeworks_screen.dart';

class HwBottomSheet extends StatelessWidget {
  const HwBottomSheet({
    super.key,
    required this.subjectController,
    required this.nameController,
    required this.dateController,
    required this.onSave,
  });

  final TextEditingController subjectController;
  final TextEditingController nameController;
  final TextEditingController dateController;
  final void Function() onSave;

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
                  onPressed: onSave,
                  child: const Text('Save'),
                )
              ],
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Name of homework'),
            ),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(hintText: 'Subject'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Deadline:'),
                Text(dateController.toString()),
              ],
            ),
            OutlinedButton(
              child: const Text('choose date'),
              onPressed: () {
                Future<DateTime?> dateController = 
                showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.utc(2030),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
