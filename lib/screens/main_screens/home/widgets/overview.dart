import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/database/settings_database.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/roboto_serif.dart';

class Overview extends ConsumerWidget {
  const Overview({
    super.key,
    required this.hwNumberOfIncomplete,
    required this.hwNumberOfMissed,
    required this.examNumberOfIncomplete,
  });

  final int hwNumberOfIncomplete;
  final int hwNumberOfMissed;
  final int examNumberOfIncomplete;

  String get greetingTime {
    final hour = TimeOfDay.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'morning';
    } else if (hour >= 12 && hour < 19) {
      return 'afternoon';
    } else if (hour >= 19 && hour < 22) {
      return 'evening';
    } else {
      return 'night';
    }
  }

  /// return 'no' if the int == 0
  String numberOrNo(int number, BuildContext context) {
    if (number == 0) {
      return context.loc.zero;
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final showMissed = hwNumberOfMissed != 0;

    String? userName = settings.get(Setting.userName);
    bool showUserName = ref.watch(greetUsernameProvider) && userName != null;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${context.loc.greetingByHour(greetingTime)}${showUserName ? ', ${userName.toVocative()}' : ''}',
            style: robotoSerif(
              size: 36,
              color: colorScheme.onPrimaryContainer,
              width: 50,
              weight: 700,
              grade: -50,
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              text: '${context.loc.youHave} ',
              style: textTheme.bodyLarge,
              children: [
                if (showMissed)
                  TextSpan(
                    text:
                        '$hwNumberOfMissed ${context.loc.missedHomework(hwNumberOfMissed).toLowerCase()}, ',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                TextSpan(
                  text: numberOrNo(hwNumberOfIncomplete, context),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      ' ${context.loc.upcomingHomework(hwNumberOfIncomplete).toLowerCase()} ${context.loc.and} ',
                ),
                TextSpan(
                  text: numberOrNo(examNumberOfIncomplete, context),
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      ' ${context.loc.upcomingExams(examNumberOfIncomplete).toLowerCase()}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
