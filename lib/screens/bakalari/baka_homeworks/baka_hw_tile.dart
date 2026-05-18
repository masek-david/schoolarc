import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/buttons/icon_button_m3e.dart';
import 'package:schoolarc/models/bakalari/baka_hw_model.dart';
import 'package:schoolarc/screens/bakalari/baka_homeworks/baka_hw_add_bottom_sheet.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';

class BakaHwTile extends StatelessWidget {
  const BakaHwTile({
    super.key,
    required this.hw,
    required this.onSave,
  });

  final BakaHomework hw;
  final Function(bool isHomework, BakaHomework hw) onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButtonM3E(
          onPressed: () {
            showModalBottomSheet(
              context: context,
              builder: (context) =>
                  BakaHwAddBottomSheet(onSave: onSave, hw: hw),
            );
          },
          icon: hw.alreadyAdded
              ? const Icon(Icons.check_circle_outline_rounded)
              : const Icon(Icons.add_circle_outline_rounded),
        ),
        Expanded(
          child: HwTile(
            hw: hw.copyWith(isCompleted: hw.alreadyAdded).toHw(),
            showBorderIfMissed: false,
            showCompletion: false,
            onDelete: null,
            onConvert: null,
            onChangedCompletion: (p0) {},
            onEdit: () {
              showModalBottomSheet(
                context: context,
                builder: (context) =>
                    BakaHwAddBottomSheet(onSave: onSave, hw: hw),
              );
            },
          ),
        ),
      ],
    );
  }
}
