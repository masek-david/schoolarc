import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class BetaIcon extends StatelessWidget {
  const BetaIcon({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: .center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
          decoration: BoxDecoration(
            border: Border.all(
              color: color ?? context.col.onSurface,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            'BETA',
            style: TextStyle(
              fontFamily: 'Monospace',
              fontSize: 9,
              fontWeight: const FontWeight(1000),
              color: color ?? context.col.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}