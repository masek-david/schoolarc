import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HomeworkTile extends StatelessWidget {
  const HomeworkTile({
    super.key,
    required this.hwText,
    required this.hwDeadline,
    required this.hwSubject,
    required this.completion,
    required this.onChanged,
    required this.deleteFunction,
  });

  final String hwText;
  final String hwDeadline;
  final String hwSubject;
  final bool completion;
  final Function(bool?) onChanged;
  final Function(BuildContext)? deleteFunction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: deleteFunction,
              icon: Icons.delete,
              backgroundColor: Colors.red,
              borderRadius: BorderRadius.circular(10),
              flex: 10,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: const Color.fromARGB(255, 243, 237, 246),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: [
              Row(
                children: [
                  Container(
                    // padding: EdgeInsets.all(12),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromARGB(255, 234, 221, 255),
                    ),
                    child: Center(
                        child: Text(
                      hwSubject,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    )),
                  ),
                  const SizedBox(width: 10),
                  Text(hwText),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(hwDeadline),
                  Checkbox(
                    value: completion,
                    onChanged: onChanged,
                    shape: const CircleBorder(),
                  )
                ],
              ),
            ],
          ),
          // ),
        ),
      ),
    );
  }
}
