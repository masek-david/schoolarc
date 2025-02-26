import 'package:flutter/material.dart';
import 'package:school_manager/models/bakalari/baka_hw_model.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/show_adaptive_dialog.dart';

class BakaHwTile extends StatelessWidget {
  const BakaHwTile({
    super.key,
    required this.hw,
    required this.onAddHw,
    required this.onAddExam,
  });

  final BakaHomework hw;
  final Function() onAddHw;
  final Function() onAddExam;

  @override
  Widget build(BuildContext context) {
    if (!hw.alreadySeen) {
      bakaHomeworkService.seenHomework(hw.bakaId);
    }

    if (hw.alreadyAdded) {
      hw.isCompleted = true;
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
                  title: Text('This homework has been already added'),
                  content: Text('Do you want to add it again?'),
                  actions: [
                    adaptiveDialogButton(
                      context: context,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text('Cancel'),
                    ),
                    adaptiveDialogButton(
                      context: context,
                      child: Text('Add as homework'),
                      onPressed: () {
                        onAddHw();
                        Navigator.pop(context);
                      },
                    ),
                    adaptiveDialogButton(
                      context: context,
                      child: Text('Add as a exam'),
                      onPressed: () {
                        onAddExam();
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              } else {
                onAddHw();
              }
            },
            icon: hw.alreadyAdded
                ? const Icon(Icons.check_circle_outline)
                : const Icon(Icons.add_circle_outline),
          ),
          Expanded(
            child: HomeworkTile(
              hw: hw.toHwDTO(),
              borderIfMissed: false,
              showCompletion: false,
              onDelete: null,
              onConvert: null,
              onChangedCompletion: (p0) {},
              onEdit: () {
                showDialogAdaptive(
                  context: context,
                  title: Text(hw.subject?.name ?? ''),
                  content: Text(hw.text),
                  actions: [
                    adaptiveDialogButton(
                      context: context,
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    adaptiveDialogButton(
                      context: context,
                      child: Text('Add as homework'),
                      onPressed: () {
                        onAddHw();
                        Navigator.pop(context);
                      },
                    ),
                    adaptiveDialogButton(
                      context: context,
                      child: Text('Add as a exam'),
                      onPressed: () {
                        onAddExam();
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
