import 'package:flutter/material.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/services/bakalari/baka_service.dart';
import 'package:school_manager/tasks_app.dart';

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
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('This homework has already been added'),
                    content: Text('Do you want to add it again?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Close'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onAdd();
                        },
                        child: Text('Add'),
                      ),
                    ],
                  ),
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
            child: AbsorbPointer(
              child: HomeworkTile(
                hw: hw,
                borderIfMissed: false,
                showCompletion: false,
                onChangedCompletion: (p0) {},
                onDelete: () {},
                onEdit: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }
}
