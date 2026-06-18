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
              final isSelected = index == selectedColorIndex;
              final foregroundColor = _foregroundColors[index];
              final size = 50.0;

              return RawButtonM3E(
                child: null,
                selected: isSelected,
                outlineWidth: null,
                outlineColor: null,
                iconSpacing: 0,
                onPressed: () {
                  vibrate.medium();
                  onChanged(color, index);
                },
                backgroundColor: WidgetStateColor.fromMap({
                  WidgetState.any: color,
                }),
                foregroundColor: WidgetStateColor.fromMap({
                  WidgetState.any: foregroundColor,
                }),
                elevation: const WidgetStateProperty.fromMap({
                  WidgetState.any: 1,
                }),
                width: size,
                height: size,
                iconSize: 40,
                radius: WidgetStateProperty.fromMap({
                  WidgetState.pressed: .circular(12),
                  WidgetState.selected: .circular(16),
                  WidgetState.any: .circular(size / 2),
                }),
                padding: 0,
                fontSize: 0,
                icon: isSelected
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
