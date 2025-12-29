import 'package:flutter/material.dart';
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

              return ClipRRect(
                borderRadius: BorderRadius.circular(1000),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isHighlighted
                        ? Border.all(
                            color: Theme.of(context).colorScheme.onSurface,
                            width: 4,
                          )
                        : null,
                    color: color,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        vibrate.medium();
                        onChanged(color);
                      },
                      child: isHighlighted ? const Icon(Icons.check) : null,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
