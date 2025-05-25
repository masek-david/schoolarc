import 'package:flutter/material.dart';
import 'package:school_manager/models/priority_model.dart';

@Deprecated('use new instead')
class PriorityPicker extends StatelessWidget {
  const PriorityPicker({
    super.key,
    required this.pickedPriority,
    required this.onSelected,
  });

  final int pickedPriority;
  final void Function(int value) onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 4,
      itemBuilder: (context, index) {
        bool isSelected = index == pickedPriority;
        TaskPriority priority = TaskPriority(index);
        final scheme = ColorScheme.fromSeed(
          seedColor: priority.getColor(context),
          brightness: Theme.of(context).brightness,
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        );

        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: ChoiceChip(
            selected: isSelected,
            onSelected: (value) => onSelected(index),
            selectedColor: scheme.primaryContainer,
            backgroundColor: scheme.surfaceContainer,
            checkmarkColor: scheme.onPrimaryContainer,
            label: Text(
              priority.name,
              style: TextStyle(
                color: isSelected ? scheme.onPrimaryContainer : scheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}
