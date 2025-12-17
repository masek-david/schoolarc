import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_refresh_indicator.dart';

// Source - https://stackoverflow.com/a
// Posted by Rémi Rousselet, modified by community. See post 'Timeline' for change history
// Retrieved 2025-12-06, License - CC BY-SA 4.0

class _InvisibleBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

ScrollBehavior _getDefaultScrollBehaviour() {
  switch (defaultTargetPlatform) {
    case TargetPlatform.macOS:
    case TargetPlatform.iOS:
      return const CupertinoScrollBehavior();
    case TargetPlatform.linux:
    case TargetPlatform.windows:
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
      return const MaterialScrollBehavior();
  }
}

class NonScrollableRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;

  const NonScrollableRefreshIndicator({
    required this.child,
    required this.onRefresh,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: ((_, constraints) {
        return ExpressiveRefreshIndicator(
          onRefresh: onRefresh,
          child: ScrollConfiguration(
            behavior: _InvisibleBehavior(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ScrollConfiguration(
                behavior: _getDefaultScrollBehaviour(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxHeight: constraints.maxHeight,
                  ),
                  child: child,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
