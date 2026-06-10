import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/raw_button_m3e.dart';
import 'package:schoolarc/utils/globals.dart';

class ColorPickerAction extends StatelessWidget {
  const ColorPickerAction({
    super.key,
    required this.onChanged,
    required this.color,
  });

  final void Function(Color color, int colorIndex) onChanged;
  final Color color;

  /// contrasting colors for the [presetColors] set in globals.dart
  static const _foregroundColors = [
    Colors.white,
    Colors.white,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.black,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
    Colors.white,
  ];

  @override
  Widget build(BuildContext context) {
    int? selectedColorIndex;

    for (int i = 0; i < presetColors.length; i++) {
      if (presetColors[i].toARGB32() == color.toARGB32()) {
        selectedColorIndex = i;
        break;
      }
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 4,
          runSpacing: 4,
          alignment: WrapAlignment.center,
          children: List.generate(
            presetColors.length,
            (index) {
              final color = presetColors[index];
              final isHighlighted = index == selectedColorIndex;
              final foregroundColor = _foregroundColors[index];

              // TODO toggle m3e button, animated checkmark
              return RawButtonM3E(
                onPressed: () {
                  vibrate.medium();
                  onChanged(color, index);
                },
                backgroundColor: color,
                foregroundColor: foregroundColor,
                elevation: 1,
                hoverElevation: 0,
                width: 50,
                height: 50,
                iconSize: 40,
                iconPadding: 0,
                radius: isHighlighted ? 12 : 25,
                pressedRadius: 8,
                padding: 0,
                fontSize: 0,
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
