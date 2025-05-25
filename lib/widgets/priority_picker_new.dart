import 'package:flutter/material.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/widgets/group_button.dart';

class PriorityPickerNew extends StatefulWidget {
  const PriorityPickerNew({
    super.key,
    required this.initialPriority,
    required this.onSelected,
  });

  final int initialPriority;
  final void Function(int value) onSelected;

  @override
  State<PriorityPickerNew> createState() => _PriorityPickerNewState();
}

class _PriorityPickerNewState extends State<PriorityPickerNew> {
  late int pickedPriority = widget.initialPriority;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        4,
        (index) {
          bool isSelected = index == widget.initialPriority;
          TaskPriority priority = TaskPriority(index);
          final scheme = ColorScheme.fromSeed(
            seedColor: priority.getColor(context),
            brightness: Theme.of(context).brightness,
            dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          );

          return GroupButton(
            roundedLeft: false,
            roundedRight: true,
            child: Text(
              priority.name,
              style: TextStyle(
                color: isSelected ? scheme.onPrimaryContainer : scheme.primary,
              ),
            ),
          );

          // return Padding(
          //   padding: const EdgeInsets.only(right: 8),
          //   child: ChoiceChip(
          //     selected: isSelected,
          //     onSelected: (value) => widget.onSelected(index),
          //     selectedColor: scheme.primaryContainer,
          //     backgroundColor: scheme.surfaceContainer,
          //     checkmarkColor: scheme.onPrimaryContainer,
          //     label: Text(
          //       priority.name,
          //       style: TextStyle(
          //         color:
          //             isSelected ? scheme.onPrimaryContainer : scheme.primary,
          //       ),
          //     ),
          //   ),
          // );
        },
      ),
    );
  }
}
