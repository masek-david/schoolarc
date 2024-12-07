import 'package:flutter/material.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/tasks_app.dart';

class Overview extends StatelessWidget {
  const Overview({
    super.key,
    required this.hwNumberOfIncomplete,
    required this.hwNumberOfMissed,
    required this.examNumberOfIncomplete,
  });

  final int hwNumberOfIncomplete;
  final int hwNumberOfMissed;
  final int examNumberOfIncomplete;

  String get welcomeText {
    final hour = TimeOfDay.now().hour;

    if (hour >= 5 && hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else if (hour < 21) {
      return 'Good evening';
    } else {
      return 'Good night';
    }
  }

  /// return 'no' if the int == 0
  String numberWithNo(int number) {
    if (number == 0) {
      return 'no';
    }
    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final showMissed = hwNumberOfMissed != 0;

    String? userName = settings.get(Setting.userName);
    bool showUserName =
        settings.get(Setting.homeShowUserName) && userName != null;

    return Padding(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$welcomeText${showUserName ? ', $userName' : ''}',
            style: textTheme.headlineLarge,
          ),
          SizedBox(height: 12),
          RichText(
            text: TextSpan(
              text: 'You have ',
              style: textTheme.bodyLarge,
              children: [
                if (showMissed)
                  TextSpan(
                    text:
                        '${numberWithNo(hwNumberOfMissed)} missed homework${hwNumberOfMissed != 1 ? 's' : ''}, ',
                    style: TextStyle(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                TextSpan(
                  text: numberWithNo(hwNumberOfIncomplete),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      ' upcoming homework${hwNumberOfIncomplete != 1 ? 's' : ''} and ',
                ),
                TextSpan(
                  text: numberWithNo(examNumberOfIncomplete),
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text:
                      ' upcoming exam${examNumberOfIncomplete != 1 ? 's' : ''}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
