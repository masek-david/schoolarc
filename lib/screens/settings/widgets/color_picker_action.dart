import 'package:flutter/material.dart';
import 'package:m3e_widgets/m3e_widgets.dart';
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
              final isSelected = index == selectedColorIndex;
              final foregroundColor = _foregroundColors[index];
              final size = 50.0;

              return M3EToggleButton(
                checkedIcon: const Icon(Icons.check_rounded),
                onCheckedChange: (value) {
                  if (value) {
                    vibrate.medium();
                    onChanged(color, index);
                  }
                },
                checked: isSelected,
                size: M3EButtonSize.custom(
                  width: size,
                  height: size,
                  iconSize: 40,
                  hPadding: 0,
                ),
                icon: const SizedBox.shrink(),
                decoration: M3EToggleButtonDecoration(
                  pressedRadius: 4,
                  foregroundColor: WidgetStatePropertyAll(foregroundColor),
                  backgroundColor: WidgetStatePropertyAll(color),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
