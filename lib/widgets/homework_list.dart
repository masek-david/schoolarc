import 'package:flutter/material.dart';
import 'package:schoolarc/models/homeworks/hw_model.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/text_separator.dart';
import 'package:schoolarc/widgets/tile/hw_tile.dart';

class HomeworkList extends StatelessWidget {
  const HomeworkList({
    super.key,
    required this.hwList,
    required this.onDelete,
    required this.onEdit,
    required this.onChangedCompletion,
    required this.onConvert,
    required this.text,
    this.draggable = false,
    this.showDates = true,
  });

  final List<Homework> hwList;
  final void Function(Homework hw) onDelete;
  final void Function(Homework hw) onConvert;
  final void Function(Homework hw) onEdit;
  final void Function(Homework hw, bool value) onChangedCompletion;
  final bool draggable;
  final bool showDates;
  final String? text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (text != null) TextSeparator(text: text!, greydOut: hwList.isEmpty),
        ...List.generate(
          hwList.length,
          (index) {
            Homework hw = hwList[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: HwTile(
                // must be here
                key: ValueKey('hwTile ${hw.id}'),
                hw: hw,
                draggable: draggable,
                showDate: showDates,
                onChangedCompletion: (value) => onChangedCompletion(hw, value),
                onDelete: () => onDelete(hw),
                onEdit: () => onEdit(hw),
                onConvert: () => onConvert(hw),
              ),
            );
          },
        ),
      ],
    );
  }
}
