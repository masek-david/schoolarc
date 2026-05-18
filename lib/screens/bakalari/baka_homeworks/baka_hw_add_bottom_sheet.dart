import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/button_m3e.dart';
import 'package:schoolarc/models/bakalari/baka_hw_model.dart';
import 'package:schoolarc/models/priority_model.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/widgets/priority_picker.dart';

class BakaHwAddBottomSheet extends StatefulWidget {
  const BakaHwAddBottomSheet({
    super.key,
    required this.hw,
    required this.onSave,
  });

  final BakaHomework hw;
  final Function(bool isHomework, BakaHomework hw) onSave;

  @override
  State<BakaHwAddBottomSheet> createState() => _BakaHwAddBottomSheetState();
}

class _BakaHwAddBottomSheetState extends State<BakaHwAddBottomSheet> {
  int pickedPriority = 0;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        spacing: 12,
        children: [
          Text(
            widget.hw.subject?.name ?? '',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(widget.hw.text),
          const Divider(),
          SizedBox(
            height: 40,
            child: PriorityPicker(
              selectedPriority: pickedPriority,
              onSelected: (value) => setState(() {
                pickedPriority = value;
              }),
            ),
          ),
          if (widget.hw.alreadyAdded)
            Row(
              spacing: 8,
              children: [
                Icon(Icons.info, color: errorColor),
                Text(
                  context.loc.homeworkAlreadyAdded,
                  style: TextStyle(color: errorColor),
                ),
              ],
            ),
          if (widget.hw.subject?.id == '')
            Row(
              spacing: 8,
              children: [
                Icon(Icons.info, color: errorColor),
                Expanded(
                  child: Text(
                    '${context.loc.subjectHasntBeenAdded}\n${context.loc.tryImportingSubjectFromBakalari}',
                    style: TextStyle(color: errorColor),
                  ),
                ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ButtonM3E.filled(
                size: .medium,
                onPressed: () {
                  widget.onSave(
                    true,
                    widget.hw.copyWith(
                      priority: TaskPriority(pickedPriority),
                    ),
                  );
                },
                child: Text(context.loc.addAsHomework),
              ),
              ButtonM3E.filled(
                size: .medium,
                onPressed: () {
                  widget.onSave(
                    false,
                    widget.hw.copyWith(
                      priority: TaskPriority(pickedPriority),
                    ),
                  );
                },
                child: Text(context.loc.addAsExam),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
