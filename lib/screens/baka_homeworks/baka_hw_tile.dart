import 'package:flutter/material.dart';
import 'package:school_manager/models/bakalari/baka_hw_model.dart';
import 'package:school_manager/screens/baka_homeworks/baka_hw_add_bottom_sheet.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';
import 'package:school_manager/tasks_app.dart';

class BakaHwTile extends StatelessWidget {
  const BakaHwTile({
    super.key,
    required this.hw,
    required this.onSave,
  });

  final BakaHomework hw;
  final Function(bool isHomework, BakaHomework hw) onSave;

  @override
  Widget build(BuildContext context) {
    if (!hw.alreadySeen) {
      bakaHomeworkService.seenHomework(hw.bakaId);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) =>
                    BakaHwAddBottomSheet(onSave: onSave, hw: hw),
              );
            },
            icon: hw.alreadyAdded
                ? const Icon(Icons.check_circle_outline)
                : const Icon(Icons.add_circle_outline),
          ),
          Expanded(
            child: HomeworkTile(
              hw: hw.copyWith(isCompleted: hw.alreadyAdded).toHwDTO(),
              borderIfMissed: false,
              showCompletion: false,
              onDelete: null,
              onConvert: null,
              onChangedCompletion: (p0) {},
              onEdit: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) =>
                      BakaHwAddBottomSheet(onSave: onSave, hw: hw),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
