import 'package:flutter/material.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/widgets/group_button.dart';

class PriorityPickerNew extends StatefulWidget {
  const PriorityPickerNew({
    super.key,
    required this.selectedPriority,
    required this.onSelected,
  });

  final int selectedPriority;
  final void Function(int value) onSelected;

  @override
  State<PriorityPickerNew> createState() => _PriorityPickerNewState();
}

class _PriorityPickerNewState extends State<PriorityPickerNew>
    with SingleTickerProviderStateMixin {
  late int priorityForAnimation = widget.selectedPriority;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 2,
      children: List.generate(
        4,
        (index) {
          bool isSelected = index == widget.selectedPriority;
          TaskPriority priority = TaskPriority(index);
          final scheme = ColorScheme.fromSeed(
            seedColor: priority.getColor(context),
            brightness: Theme.of(context).brightness,
            dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          );

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double flex = 0;

              if (index == priorityForAnimation) {
                flex = _controller.value;
              }
              if ((priorityForAnimation - index).abs() == 1) {
                if (priorityForAnimation == 0 || priorityForAnimation == 3) {
                  flex = -_controller.value;
                } else {
                  flex = -_controller.value / 2;
                }
              }
              return GroupButton(
                roundedLeft: index == 0,
                roundedRight: index == 3,
                selectedColor: scheme.primaryContainer,
                backgroundColor: scheme.surfaceContainerHigh,
                selected: isSelected,
                onTapDown: () {
                  setState(() {
                    priorityForAnimation = index;
                  });
                  _controller.animateTo(1);
                },
                onTapCancel: () {
                  _controller.animateBack(0);
                },
                onSelected: () {
                  widget.onSelected(index);
                  setState(() {
                    priorityForAnimation = index;
                  });
                  if (index != widget.selectedPriority) {
                    _controller.forward().then(
                          (value) => _controller.reverse(),
                        );
                  }
                },
                flex: flex,
                child: Text(
                  priority.name,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? scheme.onPrimaryContainer : scheme.primary,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
