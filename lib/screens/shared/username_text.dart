import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:schoolarc/models/group_models.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';

Color colorFromString(String input, bool isDark) {
  final hash = input.codeUnits.fold(0, (prev, elem) => prev + elem);
  final rnd = Random(hash);
  return HSLColor.fromAHSL(
    1.0,
    rnd.nextDouble() * 360,
    0.8,
    isDark ? 0.15 : 0.8,
  ).toColor();
}

class NicknameText extends StatelessWidget {
  const NicknameText({
    super.key,
    required this.user,
    this.radius = 14,
    this.showOnlyIcon = false,
  });

  final Member user;
  final double radius;
  final bool showOnlyIcon;

  @override
  Widget build(BuildContext context) {
    final name = user.name;
    if (user.id == 'ELQJHNXQ3LRSSokMMZWubwRUJeR2') {
      final col = context.col;

      final icon = ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(100),
        child: SizedBox(
          height: radius * 2,
          width: radius * 2,
          child: AnimatedMeshGradient(
            colors: [
              col.primary,
              col.secondary,
              col.secondaryContainer,
              col.tertiary,
            ],
            options: AnimatedMeshGradientOptions(),
          ),
        ),
      );

      if (showOnlyIcon) return icon;

      return Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          icon,
          Text(
            name,
            style: robotoSerif(color: col.onPrimaryContainer, weight: 600),
          )
        ],
      );
    }

    final icon = CircleAvatar(
      radius: radius,
      backgroundColor: colorFromString(user.id, context.isDark),
      child: name == ''
          ? Icon(
              Icons.person,
              color: context.isDark
                  ? Colors.white.withAlpha(50)
                  : Colors.black.withAlpha(100),
            )
          : Text(
              name[0],
              style: TextStyle(
                fontSize: radius * 1.2,
                fontWeight: FontWeight.bold,
              ),
            ),
    );

    if (showOnlyIcon) return icon;

    return Row(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        Text(
          name == '' ? 'No name' : name,
          style:
              name == '' ? const TextStyle(fontStyle: FontStyle.italic) : null,
        ),
      ],
    );
  }
}
