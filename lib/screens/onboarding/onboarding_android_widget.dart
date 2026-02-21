import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:schoolarc/screens/settings/widgets/setting_tile.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class OnboardingAndroidWidget extends StatelessWidget {
  const OnboardingAndroidWidget({super.key, required this.next});

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
                  context.loc.addWidgetToHomescreen,
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
                      'assets/images/android_widgets_${context.isDark ? 'dark' : 'light'}.png',
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
                title: context.loc.yes,
                leading: const Icon(Icons.check_rounded),
                onTap: (context) async {
                  // TODO test
                  HomeWidget.requestPinWidget(
                    androidName: 'MainWidgetReceiver',
                    qualifiedAndroidName:
                        'cz.masci.schoolarc.MainWidgetReceiver',
                  );

                  next();
                },
              );
            },
          ),
          AnimatedItem(
            builder: (isShown) {
              return SettingTile(
                titleColor: context.col.surfaceContainerHighest,
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
