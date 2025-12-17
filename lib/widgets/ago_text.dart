import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class AgoText extends ConsumerWidget {
  const AgoText({
    super.key,
    required this.stream,
  });

  final StreamProvider<Duration?> stream;

  String formatDuration(BuildContext context, Duration d) {
    if (d.inSeconds < 60) {
      return '${d.inSeconds}${context.loc.secondShort}';
    } else if (d.inMinutes < 60) {
      return '${d.inMinutes}${context.loc.minutesShort}';
    } else if (d.inHours < 24) {
      return '${d.inHours}${context.loc.hoursShort}';
    } else {
      return '${d.inDays}${context.loc.daysShort}';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Duration? duration;
    ref.watch(stream).whenData(
          (value) => duration = value,
        );

    if (duration == null) {
      return const SizedBox();
    }

    final color = getSubtleTextColor(context);

    return Row(
      spacing: 2,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Transform.scale(
          scale: 0.7,
          child: Icon(Icons.history, color: color),
        ),
        Text(
          formatDuration(context, duration!),
          style: context.txt.labelMedium!.copyWith(color: color),
        ),
      ],
    );
  }
}
