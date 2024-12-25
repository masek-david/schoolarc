import 'package:flutter/material.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/services/bakalari/baka_service.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';

class BakaHwTile extends StatelessWidget {
  const BakaHwTile({
    super.key,
    required this.hw,
    required this.onAdd,
  });

  final BakaHomework hw;
  final Function() onAdd;

  @override
  Widget build(BuildContext context) {
    if (!hw.alreadySeen) {
      bakaHomeworkService.seenHomework(hw.bakaId);
    }

    if (hw.alreadyAdded) {
      hw.completion = true;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (hw.alreadyAdded) {
                showDialogAdaptive(
                  context: context,
                  title: Text('This homework has already been added'),
                  content: Text('Do you want to add it again?'),
                  actions: [
                    adaptiveDialogButton(
                      context: context,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Close'),
                    ),
                    adaptiveDialogButton(
                      context: context,
                      onPressed: () {
                        Navigator.pop(context);
                        onAdd();
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              } else {
                onAdd();
              }
            },
            icon: hw.alreadyAdded
                ? const Icon(Icons.check_circle_outline)
                : const Icon(Icons.add_circle_outline),
          ),
          Expanded(
            child: HomeworkTile(
              hw: hw,
              borderIfMissed: false,
              showCompletion: false,
              onDelete: null,
              onChangedCompletion: (p0) {},
              onTap: () {
                showDialogAdaptive(
                  context: context,
                  title: Text(hw.subject?.name ?? ''),
                  content: Text(hw.text),
                  actions: [
                    adaptiveDialogButton(
                      context: context,
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    adaptiveDialogButton(
                      context: context,
                      child: Text('Add'),
                      onPressed: () {
                        onAdd();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
