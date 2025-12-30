import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';

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
    return CustomMaterialIndicator(
      onRefresh: () async {
        vibrate.release();
        await onRefresh();
      },
      onStateChanged: (change) {
        if(change.newState.isArmed){
          vibrate.medium();
        }
      },
      notificationPredicate: enabled
          ? CustomRefreshIndicator.defaultScrollNotificationPredicate
          : (_) => false,
      backgroundColor: context.col.primaryContainer,
      indicatorSize: const Size(48, 48),
      displacement: 20,
      indicatorBuilder: (context, controller) {
        return Padding(
          padding: const EdgeInsets.all(6),
          child: MyExpressiveLoadingIndicator(
            color: context.col.onPrimaryContainer,
            progress: controller.state.isLoading
                ? null
                : controller.value.clamp(0, 1),
          ),
        );
      },
      child: child,
    );
  }
}
