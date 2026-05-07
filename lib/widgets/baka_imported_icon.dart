import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class BakaImportedIcon extends StatelessWidget {
  const BakaImportedIcon({super.key, this.color, this.showIcon = true});

  final Color? color;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: .center,
      children: [
        if (showIcon) Icon(Icons.download_rounded, size: 14, color: color),
        Container(
          width: 22,
          height: 22,
          decoration: ShapeDecoration(
            shape: StarBorder.polygon(
              pointRounding: 0.2,
              sides: 6,
              side: BorderSide(
                color: color ?? context.col.onSurface,
                width: 2.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


