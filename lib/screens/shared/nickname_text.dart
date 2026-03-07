import 'dart:math';

import 'package:flutter/material.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:schoolarc/models/group_models.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';

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
    this.isLoading = false,
    this.editNickname,
  });

  final Member? user;
  final double radius;
  final bool showOnlyIcon;
  final bool isLoading;
  final void Function()? editNickname;

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? '';
    final loggedIn = user != null;
    final col = context.col;
    late Widget avatar;
    late TextStyle textStyle;
    late String text;

    if (isLoading) {
      text = context.loc.loading;

      textStyle = context.txt.headlineSmall!.copyWith(
        fontStyle: FontStyle.italic,
      );

      avatar = CircleAvatar(
        radius: radius,
        child: ExpressiveLoadingIndicator(size: radius * 1.7),
      );
    } else if (user?.id == 'ELQJHNXQ3LRSSokMMZWubwRUJeR2') {
      text = user!.name;

      textStyle = robotoSerif(color: col.onPrimaryContainer, weight: 600);

      avatar = ClipRRect(
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
    } else {
      text = loggedIn ? user!.name : context.loc.loggedOut;

      textStyle = context.txt.headlineMedium!.copyWith(
        color: loggedIn ? null : col.surfaceContainerHighest,
        fontStyle: name == '' ? FontStyle.italic : null,
      );

      avatar = CircleAvatar(
        radius: radius,
        backgroundColor: loggedIn
            ? colorFromString(user!.id, context.isDark)
            : col.surfaceContainerLow,
        foregroundColor: context.col.onSurface,
        child: name == ''
            ? Icon(
                loggedIn ? Icons.person_rounded : Icons.person_off_rounded,
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
    }
    if (showOnlyIcon) return avatar;

    return Row(
      spacing: 8,
      mainAxisSize: MainAxisSize.min,
      children: [
        avatar,
        Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                Text(text, style: textStyle),
                if (editNickname != null && !isLoading && loggedIn)
                  IconButton(
                    color: context.col.onSecondaryContainer,
                    tooltip: context.loc.changeNickname,
                    onPressed: editNickname,
                    icon: const Icon(Icons.edit_rounded),
                  ),
              ],
            ),
            if (user?.email != null)
              Text(
                user!.email!,
                style: context.txt.labelMedium,
              ),
            if (user?.email != null) const SizedBox(height: 8),
          ],
        ),
      ],
    );
  }
}
