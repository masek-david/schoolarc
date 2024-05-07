import 'package:flutter/material.dart';
import 'package:school_manager/homeworks_screen.dart';

class MyFAB extends StatelessWidget {
  const MyFAB({
    super.key,
    // required this.addHW,
  });

  // final void Function() addHW;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Save'),
                      )
                    ],
                  ),
                  const TextField(
                    decoration: InputDecoration(hintText: 'Name of homework'),
                  ),
                  const TextField(
                    decoration: InputDecoration(hintText: 'Subject'),
                  ),
                  const TextField(
                    decoration: InputDecoration(hintText: 'Deadline date'),
                  ),
                  OutlinedButton(
                      child: const Text('choose date'),
                      onPressed: () {
                        showDatePicker(
                          context: context,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.utc(2030),
                        );
                      }),
                ],
              ),
            ),
          );
        });
  }
}
