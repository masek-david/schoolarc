import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class TileSlidable extends StatelessWidget {
  const TileSlidable({
    super.key,
    required this.child,
    this.slidableController,
    this.onDelete,
    this.onConvert,
    required this.borderRadius,
    required this.isHomework,
  });

  final Widget child;
  final SlidableController? slidableController;
  final double borderRadius;
  final bool isHomework;
  final void Function()? onDelete;
  final void Function()? onConvert;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double extentRatio = 135 / constraints.maxWidth;

        if (extentRatio > 1) {
          extentRatio = 1;
        }

        return Slidable(
          groupTag: 0,
          controller: slidableController,
          startActionPane: onConvert == null
              ? null
              : ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: extentRatio,
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        vibrate.medium();
                        onConvert!();
                      },
                      icon: Icons.swap_vertical_circle_outlined,
                      label: isHomework
                          ? context.loc.toExam
                          : context.loc.toHomework,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onTertiaryContainer,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(borderRadius),
                      flex: 10,
                    ),
                  ],
                ),
          endActionPane: onDelete == null
              ? null
              : ActionPane(
                  motion: const StretchMotion(),
                  extentRatio: extentRatio,
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        vibrate.medium();
                        onDelete!();
                      },
                      icon: Icons.delete,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onErrorContainer,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(borderRadius),
                      flex: 10,
                    ),
                  ],
                ),
          child: child,
        );
      },
    );
  }
}
