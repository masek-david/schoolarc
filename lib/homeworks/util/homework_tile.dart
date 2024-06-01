import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/homeworks/util/my_checkbox.dart';

class HomeworkTile extends StatelessWidget {
  const HomeworkTile({
    super.key,
    required this.hwText,
    required this.hwDeadline,
    required this.hwSubject,
    required this.hwCompletion,
    required this.hwPriority,
    required this.onChangedCompletion,
    required this.onDelete,
    required this.onEdit,
  });

  final String hwSubject;
  final String hwText;
  final DateTime hwDeadline;
  final bool hwCompletion;
  final int hwPriority;
  final Function(bool?) onChangedCompletion;
  final Function(BuildContext)? onDelete;
  final Function()? onEdit;

  @override
  Widget build(BuildContext context) {
    Color deadlineColor = Theme.of(context).colorScheme.onBackground;
    if (hwDeadline.isBefore(DateTime.now())) {
      deadlineColor = Colors.red.harmonizeWith(Theme.of(context).primaryColor);
    }
    String deadlineText = '${hwDeadline.day}.${hwDeadline.month}.';
    if (hwDeadline.year != DateTime.now().year) {
      deadlineText += ' ${hwDeadline.year}';
    } else if (deadlineText ==
        '${(DateTime.now().day) + 1}.${DateTime.now().month}.') {
      deadlineText = 'Tomorrow';
    } else if (deadlineText ==
        '${(DateTime.now().day)}.${DateTime.now().month}.') {
      deadlineText = 'Today';
    } else if (deadlineText ==
        '${(DateTime.now().day) - 1}.${DateTime.now().month}.') {
      deadlineText = 'Yesterday';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Slidable(
        groupTag: '0',
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: onDelete,
              icon: Icons.delete,
              foregroundColor: Theme.of(context).colorScheme.onError,
              backgroundColor: Theme.of(context).colorScheme.error,
              borderRadius: BorderRadius.circular(10),
              flex: 10,
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.background,
          ),
          child: InkWell(
            onTap: onEdit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      child: Center(
                        child: Text(
                          hwSubject,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(width: 210, child: Text(hwText, maxLines: 2)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 47,
                      child: Center(
                        child: Text(
                          deadlineText,
                          maxLines: 2,
                          style: TextStyle(color: deadlineColor, fontSize: 12),
                        ),
                      ),
                    ),
                    MyCheckbox(
                      value: hwCompletion,
                      priority: hwPriority,
                      onChanged: onChangedCompletion,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
