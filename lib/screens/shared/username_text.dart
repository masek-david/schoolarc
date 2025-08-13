import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:schoolarc/services/firebase/firebase_sharing_service.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/roboto_serif.dart';

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

class UsernameText extends StatelessWidget {
  const UsernameText({super.key, required this.user, this.radius = 14});

  final MyUser user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final name = user.name;
    if (user.id == 'ELQJHNXQ3LRSSokMMZWubwRUJeR2') {
      final col = context.col;

      return Row(
        spacing: 8,
        children: [
          ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(100),
            child: SizedBox(
              height: radius * 2,
              width: radius * 2,
              child: AnimatedMeshGradient(colors: [
                col.primary,
                col.secondary,
                col.secondaryContainer,
                col.tertiary,
              ], options: AnimatedMeshGradientOptions()),
            ),
          ),
          Text(
            name,
            style: robotoSerif(color: col.onPrimaryContainer, weight: 600),
          )
        ],
      );
    }

    return Row(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
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
        ),
        Text(
          name == '' ? 'No name' : name,
          style:
              name == '' ? const TextStyle(fontStyle: FontStyle.italic) : null,
        ),
      ],
    );
  }
}
