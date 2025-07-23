import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/color_extension.dart';
import 'package:schoolarc/utils/web/bar_color.dart';

class WideScreenBorders extends StatelessWidget {
  const WideScreenBorders({
    super.key,
    required this.child,
    required this.show,
  });

  final Widget child;
  final bool show;

  @override
  Widget build(BuildContext context) {
    double top = MediaQuery.paddingOf(context).top;
    double bottom = MediaQuery.paddingOf(context).bottom;

    if (kIsWeb) {
      setBarColor(Theme.of(context).colorScheme.surfaceContainer.toHexString());
    }

    if (top == 0) {
      top = 16;
    }
    if (bottom == 0) {
      bottom = 16;
    }

    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        padding: show
            ? EdgeInsets.only(top: top, bottom: bottom, right: bottom)
            : null,
        child: ClipRRect(
          borderRadius: show ? BorderRadius.circular(12) : BorderRadius.zero,
          child: child,
        ),
      ),
    );
  }
}
