import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:schoolarc/provider/bakalari/baka_homeworks_notifier.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/screens/recap/recap.dart';
import 'package:schoolarc/screens/recap/recap_button.dart';
import 'package:schoolarc/utils/color_mapper.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/drawer/drawer_button.dart';
import 'package:schoolarc/widgets/drawer/search_bar.dart';

class MyDrawer extends ConsumerWidget {
  const MyDrawer({super.key});

  void showSnackbar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = context.loc;
    final padding = MediaQuery.paddingOf(context);

    return Drawer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    SizedBox(height: padding.top),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 20, 0, 20),
                      child: SizedBox(
                        height: 100,
                        child: SvgPicture.asset(
                          'assets/schoolarc_logo.svg',
                          colorMapper: LogoColorMapper(
                            isDark:
                                Theme.of(context).brightness == Brightness.dark,
                            primaryFixedDimColor: context.col.primaryFixedDim
                                .toARGB32(),
                            secondaryColor: context.col.secondary.toARGB32(),
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(left: 8, bottom: 8, right: 8),
                      child: MySearchBar(),
                    ),
                    MyDrawerButton(
                      text: loc.subjects,
                      icon: const Icon(Icons.school_rounded),
                      showBadge: ref.watch(subjectsNonDeletedProvider).isEmpty,
                      onTap: () {
                        Navigator.restorablePushNamed(context, '/subjects');
                      },
                    ),
                    MyDrawerButton(
                      text: loc.permanentTimetable,
                      icon: const Icon(Icons.calendar_month_rounded),
                      showBadge: timetableDb.timeTable.lessonTimes.isEmpty,
                      onTap: () {
                        Navigator.restorablePushNamed(context, '/timetable');
                      },
                    ),
                    // MyDrawerButton(
                    //   text: context.loc.group,
                    //   icon: const Icon(Icons.group_rounded),
                    //   onTap: () {
                    //     Navigator.restorablePushNamed(context, '/group');
                    //   },
                    // ),
                    const Divider(indent: 16, endIndent: 16),
                    MyDrawerButton(
                      text: loc.hwFromBaka,
                      icon: const Icon(Icons.home_work_rounded),
                      onTap: () {
                        ref.read(bakaHomeworksProvider.notifier).refreshIfOld();
                        Navigator.restorablePushNamed(
                          context,
                          '/bakalari-homeworks',
                        );
                      },
                    ),
                    const Divider(indent: 16, endIndent: 16),
                    MyDrawerButton(
                      text: loc.recentlyDeleted,
                      icon: const Icon(Icons.delete_forever_rounded),
                      onTap: () {
                        Navigator.restorablePushNamed(context, '/deleted');
                      },
                    ),
                    if (kDebugMode) const Divider(indent: 16, endIndent: 16),
                    if (kDebugMode)
                      MyDrawerButton(
                        text: loc.viewDatabase,
                        icon: const Icon(Icons.data_array_rounded),
                        onTap: () {
                          Navigator.restorablePushNamed(context, '/database');
                        },
                      ),
                    if (kDebugMode)
                      MyDrawerButton(
                        text: loc.viewLogs,
                        icon: const Icon(Icons.bug_report_rounded),
                        onTap: () {
                          Navigator.restorablePushNamed(context, '/logs');
                        },
                      ),
                  ],
                ),
              ),
            ),
            if (isRecapDate())
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: RecapButton.small(context),
              ),
            MyDrawerButton(
              text: loc.viewTutorial,
              icon: const Icon(Icons.school_rounded),
              onTap: () {
                Navigator.restorablePushNamed(context, '/tutorial');
              },
            ),
            MyDrawerButton(
              text: loc.settings,
              icon: const Icon(Icons.settings_rounded),
              onTap: () {
                Navigator.restorablePushNamed(context, '/settings');
              },
            ),
            if (kDebugMode)
              GestureDetector(
                onTap: () => Navigator.restorablePushNamed(
                  context,
                  '/changelog',
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$appVersion build $appBuildNumber',
                    style: TextStyle(color: getSubtleTextColor(context)),
                  ),
                ),
              ),
            SizedBox(height: padding.bottom),
          ],
        ),
      ),
    );
  }
}
