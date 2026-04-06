import 'package:flutter/material.dart';
import 'package:schoolarc/screens/settings/setting_pages/tomorrow_notifications_page.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class OnboardingNotifications extends StatelessWidget {
  const OnboardingNotifications({super.key, required this.next});

  final void Function() next;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: AnimatedPage(
        spacing: 0,
        children: [
          AnimatedItem(
            builder: (isShown) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(8, 64, 8, 16),
                child: Text(
                  context.loc.receiveUpcomingDayNotifications,
                  style: context.txt.headlineMedium,
                ),
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Align(
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(28),
                    child: Image.asset(
                      'assets/images/android_notification_${context.isDark ? 'dark' : 'light'}.webp',
                      height: 450,
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return SettingTile(
                isFirst: true,
                title: context.loc.continueAction,
                leading: const Icon(Icons.check_rounded),
                onTap: (context) async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TomorrowNotificationsPage(
                        showMessageOnPop: false,
                      ),
                    ),
                  );
                  next();
                },
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return SettingTile(
                foregroundColor: context.col.surfaceContainerHighest,
                isLast: true,
                title: context.loc.cancel,
                leading: Icon(
                  Icons.cancel_rounded,
                  color: context.col.surfaceContainerHighest,
                ),
                onTap: (context) {
                  next();
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
