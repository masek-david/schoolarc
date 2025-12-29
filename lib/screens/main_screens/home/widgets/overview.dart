import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/provider/bakalari/username_notifier.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/fonts.dart';

class Overview extends ConsumerWidget {
  const Overview({super.key});

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

    final missedHw = ref.watch(hwMissedProvider).length;
    final upcomingHw = ref.watch(hwDataProvider).values.where(
      (element) {
        return !element.isDeleted &&
            !element.isCompleted &&
            !element.date.isBefore(Date.today());
      },
    ).length;
    final upcomingExams = ref.watch(examDataProvider).values.where(
      (element) {
        return !element.isDeleted && !element.isCompleted;
      },
    ).length;

    String? userName = ref.watch(usernameProvider);
    bool showUserName = ref.watch(greetUsernameProvider) && userName != null;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${context.loc.greetingByHour(greetingTime)}${showUserName ? ', ${userName.toVocative(context)}' : ''}',
            style: robotoSerif(
              size: 36,
              color: colorScheme.primary,
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
                if (missedHw != 0)
                  TextSpan(
                    text:
                        '$missedHw ${context.loc.missedHomework(missedHw).toLowerCase()}, ',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                TextSpan(
                  text: numberOrNo(upcomingHw, context),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      ' ${context.loc.upcomingHomework(upcomingHw).toLowerCase()} ${context.loc.and} ',
                ),
                TextSpan(
                  text: numberOrNo(upcomingExams, context),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      ' ${context.loc.upcomingExams(upcomingExams).toLowerCase()}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
