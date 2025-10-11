import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolarc/screens/main_screens/exams_screen.dart';
import 'package:schoolarc/screens/main_screens/homeworks_screen.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/task_functions.dart';
import 'package:schoolarc/widgets/floating_tab_bar.dart';

class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen>
    with SingleTickerProviderStateMixin {
  late final tabController = TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        TabBarView(
          controller: tabController,
          children: const [
            HomeworksScreen(),
            ExamsScreen(),
          ],
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: FloatingTabBar(
            controller: tabController,
            onFabTap: (page) async {
              HapticFeedback.mediumImpact();
              if (page == 0) {
                return addNewHw(context);
              } else {
                return addNewExam(context);
              }
            },
            destinations: <Destination>[
              Destination(
                icon: const Icon(Icons.assignment_outlined),
                selectedIcon: const Icon(Icons.assignment),
                label: context.loc.homework(2),
              ),
              Destination(
                icon: const Icon(Icons.school_outlined),
                selectedIcon: const Icon(Icons.school),
                label: context.loc.exams(2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
