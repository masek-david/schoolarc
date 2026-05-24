import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/utils/globals.dart';

class ColorPickerAction extends StatelessWidget {
  const ColorPickerAction({
    super.key,
    required this.onChanged,
    required this.color,
  });

  final void Function(Color color) onChanged;
  final Color color;

  static const colors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.lime,
    Colors.green,
    Colors.teal,
    Colors.cyan,
    Colors.blue,
    Colors.indigo,
    Colors.deepPurple,
    Colors.purple,
  ];

  @override
  Widget build(BuildContext context) {
    int? selectedColorIndex;

    for (int i = 0; i < colors.length; i++) {
      if (colors[i].toARGB32() == color.toARGB32()) {
        selectedColorIndex = i;
        break;
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: List.generate(
            colors.length,
            (index) {
              final color = colors[index];
              final isHighlighted = index == selectedColorIndex;

              // TODO toggle
              return IconButtonM3E(
                shape: isHighlighted ? .square : .round,
                backgroundColor: color,
                onPressed: () {
                  vibrate.medium();
                  onChanged(color);
                },
                icon: isHighlighted
                    ? const Icon(Icons.check_rounded)
                    : const SizedBox.shrink(),
              );
            },
          ),
        ),
      ),
    );
  }
}
