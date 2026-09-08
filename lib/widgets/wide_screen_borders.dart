import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/color_extension.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/web_stub.dart'
    if (dart.library.html) 'package:web/web.dart'
    as web;

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
    if (!show) return Expanded(child: child);

    final padding = MediaQuery.viewPaddingOf(context);
    double top = padding.top;
    double bottom = padding.bottom;
    double right = padding.right;

    if (kIsWeb) {
      web.window.localStorage.setItem(
        'surfaceContainer',
        context.col.surfaceContainer.toHexString(),
      );
      web.window.localStorage.setItem(
        'surface',
        context.col.surface.toHexString(),
      );
      web.window.localStorage.setItem(
        'primaryFixedDim',
        context.col.primaryFixedDim.toHexString(),
      );
      web.window.localStorage.setItem(
        'secondary',
        context.col.secondary.toHexString(),
      );
    }

    if (top == 0) {
      top = 16;
    }
    if (bottom == 0) {
      bottom = 16;
    }
    if (right == 0) {
      right = bottom;
    }

    return Expanded(
      child: Container(
        color: Theme.of(context).colorScheme.surfaceContainer,
        padding: EdgeInsets.only(top: top, bottom: bottom, right: right),
        child: ClipRRect(
          borderRadius: .circular(12),
          child: MediaQuery.removeViewPadding(
            removeTop: true,
            context: context,
            child: child,
          ),
        ),
      ),
    );
  }
}
