import 'package:flutter/material.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/widgets/animated_completion.dart';

class HomeworkList extends StatelessWidget {
  const HomeworkList({
    super.key,
    required this.hwList,
    this.draggable = false,
    this.showText = false,
    this.showDates = true,
    this.textFull = 'Homeworks',
    this.textEmpty,
    required this.onDelete,
    required this.onEdit,
    required this.onChangedCompletion, required this.onConvert,
  });

  final List<HomeworkDTO> hwList;
  final void Function(HomeworkDTO hw) onDelete;
  final void Function(HomeworkDTO hw) onConvert;
  final void Function(HomeworkDTO hw) onEdit;
  final void Function(HomeworkDTO hw, bool value) onChangedCompletion;
  final bool draggable;
  final bool showText;
  final bool showDates;
  final String textFull;
  final String? textEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hwList.isEmpty && showText)
          TextSeparator(
            text: textEmpty ?? 'No $textFull',
            greydOut: true,
          )
        else if (showText)
          TextSeparator(text: textFull),
        ...List.generate(hwList.length, (index) {
          HomeworkDTO hw = hwList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: AnimatedCompletionTile(
              hw: hw,
              draggable: draggable,
              showDate: showDates,
              onChangedCompletion: (value) => onChangedCompletion(hw, value),
              onDelete: () => onDelete(hw),
              onEdit: () => onEdit(hw),
              onConvert: () => onConvert(hw),
            ),
          );
        }),
      ],
    );
  }
}
