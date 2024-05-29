import 'package:flutter/material.dart';
import 'package:school_manager/util/homework_tile.dart';
import 'package:school_manager/data/hw_dto_model.dart';

class PriorityList extends StatefulWidget {
  const PriorityList({
    super.key,
    this.hwWithPriority,
    required this.priorityIndex,
    required this.checkBoxChange,
    required this.deleteTask,
    required this.editHW,
  });

  final int priorityIndex;
  final List<HomeworkDTO>? hwWithPriority;
  final Function(int) checkBoxChange;
  final Function(int) deleteTask;
  final void Function(int) editHW;

  @override
  State<PriorityList> createState() => PriorityListState();
}

class PriorityListState extends State<PriorityList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Priority:'),
              Text(widget.priorityIndex.toString()),
            ],
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.hwWithPriority!.length,
          itemBuilder: (context, indexInSortedList) {
            if (widget.hwWithPriority != null &&
                widget.hwWithPriority!.isEmpty) {
              return null;
            }
            HomeworkDTO hw = widget.hwWithPriority![indexInSortedList];
            return HomeworkTile(
              hwText: hw.text,
              hwDeadline: hw.deadline,
              hwSubject: hw.subject,
              hwCompletion: hw.completion,
              hwPriority: hw.priority,
              onChangedCompletion: (value) => widget.checkBoxChange(hw.index),
              onDelete: (context) => widget.deleteTask(hw.index),
              onEdit: () => widget.editHW(hw.index),
            );
          },
        ),
      ],
    );
  }
}
