import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';

class CardWithTitle extends StatelessWidget {
  const CardWithTitle({
    super.key,
    required this.text,
    required this.child,
    this.actions = const [],
    this.childPadding = const .fromLTRB(12, 0, 12, 12),
    this.highContainer = false,
    this.greydOut = false,
    this.error,
    this.errorText,
  });

  final String? text;
  final Widget? child;
  final List<Widget> actions;
  final bool highContainer;
  final bool greydOut;
  final Object? error;
  final String? errorText;

  final EdgeInsets childPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          clipBehavior: .antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: highContainer
                ? context.col.surfaceContainerLow
                : context.col.surfaceContainerLowest,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: error == null
                        ? text == null
                              ? const SizedBox.shrink()
                              : Padding(
                                  padding: const EdgeInsetsGeometry.all(16),
                                  child: Text(
                                    text!,
                                    style: context.txt.titleMedium!.copyWith(
                                      color: greydOut
                                          ? getSubtleTextColor(context)
                                          : null,
                                    ),
                                  ),
                                )
                        : ErrorTile(
                            error: error,
                            text: errorText,
                            padding: const .all(12),
                          ),
                  ),
                  ...actions,
                  const SizedBox(width: 4),
                ],
              ),
              if (child != null)
                Padding(
                  padding: childPadding,
                  child: child,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
