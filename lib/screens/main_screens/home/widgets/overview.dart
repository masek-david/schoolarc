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

  TextStyle getStyle(
    BuildContext context, {
    bool bold = false,
    bool number = false,
    Color? color,
  }) {
    return googleSansFlex(
      size: number ? 18 : 16,
      color: color,
      weight: number
          ? 800
          : bold
          ? 500
          : 300,
      roundness: number ? 100 : 0,
      width: 80,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final col = Theme.of(context).colorScheme;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${context.loc.greetingByHour(greetingTime)}${showUserName ? ', ${userName.toVocative(context)}' : ''}',
          style: robotoSerif(
            size: 36,
            color: col.primary,
            width: 50,
            weight: 700,
            grade: -50,
          ),
        ),
        RichText(
          text: TextSpan(
            text: '${context.loc.youHave} ',
            style: getStyle(context),
            children: [
              if (missedHw != 0)
                TextSpan(
                  text: '$missedHw',
                  style: getStyle(
                    context,
                    bold: true,
                    number: true,
                    color: col.error,
                  ),
                ),
              if (missedHw != 0)
                TextSpan(
                  text:
                      ' ${context.loc.missedHomework(missedHw).toLowerCase()}',
                  style: getStyle(
                    context,
                    bold: true,
                    color: col.error,
                  ),
                ),
              if (missedHw != 0)
                TextSpan(
                  text: ', ',
                  style: getStyle(context),
                ),
              TextSpan(
                text: numberOrNo(upcomingHw, context),
                style: getStyle(
                  context,
                  color: col.tertiary,
                  bold: true,
                  number: true,
                ),
              ),
              TextSpan(
                text:
                    ' ${context.loc.upcomingHomework(upcomingHw).toLowerCase()} ${context.loc.and} ',
                style: getStyle(context),
              ),
              TextSpan(
                text: numberOrNo(upcomingExams, context),
                style: getStyle(
                  context,
                  color: col.tertiary,
                  number: true,
                  bold: true,
                ),
              ),
              TextSpan(
                text:
                    ' ${context.loc.upcomingExams(upcomingExams).toLowerCase()}',
                style: getStyle(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
