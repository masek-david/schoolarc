import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/provider/time_format_notifier.dart';

/// sets alwaysUse24HourFormat for the child
class TimeFormat extends ConsumerWidget {
  const TimeFormat({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localUse24 = ref.watch(timeFormatProvider);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        alwaysUse24HourFormat: localUse24,
      ),
      child: child,
    );
  }
}
