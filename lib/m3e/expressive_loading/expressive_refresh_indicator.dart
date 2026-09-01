import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class ExpressiveRefreshIndicator extends StatelessWidget {
  const ExpressiveRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final size = 48.0;

    return CustomRefreshIndicator(
      onRefresh: () async {
        vibrate.release();
        await Future.delayed(Durations.extralong4);
        await onRefresh();
      },
      onStateChanged: (change) {
        if (change.newState.isArmed) {
          vibrate.medium();
        }
      },
      notificationPredicate: enabled
          ? CustomRefreshIndicator.defaultScrollNotificationPredicate
          : (_) => false,
      builder: (context, child, controller) {
        final progress = Curves.decelerate.transform(controller.value / 1.5);
        final scale = (controller.value * 2).clamp(0.0, 1.0);

        return Stack(
          alignment: .topCenter,
          children: [
            child,
            Positioned(
              top: 80 + progress * 80 - size,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: kElevationToShadow[8],
                    color: context.col.primaryContainer,
                    borderRadius: .circular(100),
                  ),
                  child: ExpressiveLoadingIndicator(
                    size: size,
                    color: context.col.onPrimaryContainer,
                    progress: controller.state.isLoading ? null : progress,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}
