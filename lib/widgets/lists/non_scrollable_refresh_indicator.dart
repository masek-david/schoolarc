import 'package:flutter/material.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_refresh_indicator.dart';

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
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                  maxHeight: constraints.maxHeight),
              child: child,
            ),
          ),
        );
      }),
    );
  }
}
