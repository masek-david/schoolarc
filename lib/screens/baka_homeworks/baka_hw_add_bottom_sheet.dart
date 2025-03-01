import 'package:flutter/material.dart';
import 'package:school_manager/models/bakalari/baka_hw_model.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/widgets/priority_picker.dart';

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
    final errorC = Theme.of(context).colorScheme.error;

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
          Divider(),
          SizedBox(
            height: 40,
            child: PriorityPicker(
              pickedPriority: pickedPriority,
              onSelected: (value) => setState(() {
                pickedPriority = value;
              }),
            ),
          ),
          if (widget.hw.alreadyAdded)
            Row(
              spacing: 8,
              children: [
                Icon(Icons.info, color: errorC),
                Text(
                  'This homework has been already added',
                  style: TextStyle(color: errorC),
                ),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FilledButton(
                onPressed: () => widget.onSave(
                  true,
                  widget.hw.copyWith(
                        priority: TaskPriority(pickedPriority),
                      ),
                ),
                child: Text('Add as homework'),
              ),
              FilledButton(
                onPressed: () => widget.onSave(
                  false,
                  widget.hw.copyWith(
                        priority: TaskPriority(pickedPriority),
                      ),
                ),
                child: Text('Add as a exam'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
