import 'package:flutter/material.dart';

class MyFAB extends StatelessWidget {
  const MyFAB({super.key});

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
                  )
                ],
              ),
            ),
          );
        });
  }
}
