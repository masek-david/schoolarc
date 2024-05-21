import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/util/my_checkbox.dart';

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
      deadlineColor = Theme.of(context).colorScheme.error;
    }
    String deadlineText = '${hwDeadline.day}.${hwDeadline.month}.';
    if (hwDeadline.year != DateTime.now().year) {
      deadlineText += ' ${hwDeadline.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Slidable(
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
            color: ElevationOverlay.applySurfaceTint(
                Theme.of(context).colorScheme.surface,
                Theme.of(context).colorScheme.primary,
                1),
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
                            // color: Theme.of(context).colorScheme.onPrimaryContainer,     // stejne je to bila
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(width: 220, child: Text(hwText, maxLines: 2)),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 42,
                      child: Text(
                        deadlineText,
                        maxLines: 2,
                        style: TextStyle(color: deadlineColor),
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
