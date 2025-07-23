import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';

/// sets alwaysUse24HourFormat for the child
class TimeFormat extends ConsumerWidget {
  const TimeFormat({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localUse24 = ref.watch(use24HourFormatProvider);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        alwaysUse24HourFormat: localUse24,
      ),
      child: child,
    );
  }
}
