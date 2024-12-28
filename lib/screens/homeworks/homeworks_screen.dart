import 'package:flutter/material.dart';
import 'package:school_manager/screens/current_timetable/loading_icon_button.dart';
import 'package:school_manager/screens/homeworks/widgets/priority_view.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/screen_size.dart';
import 'package:school_manager/widgets/wide_screen_app_bar.dart';

class HomeworksScreen extends StatefulWidget {
  const HomeworksScreen({super.key});

  @override
  State<HomeworksScreen> createState() => _HomeworksScreenState();
}

class _HomeworksScreenState extends State<HomeworksScreen> {
  late var hwByPriority = homeworkService.sortByPriority(null);
  late var completedHw = homeworkService.getCompletedHw(null);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    updateListView();
  }

  void updateListView() {
    if (mounted) {
      setState(() {
        hwByPriority = homeworkService.sortByPriority(context);
        completedHw = homeworkService.getCompletedHw(context);
      });
    }
  }

  void reorderHomework(int oldItemIndex, int oldPriority, int newItemIndex,
      int newPriority) async {
    await homeworkService.changeSequence(
        oldItemIndex, oldPriority, newItemIndex, newPriority);

    updateListView();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ScreenSize.isWideScreen,
      builder: (context, isWide, child) {
        return Scaffold(
          appBar: WideScreenAppBar(
            isWideScreen: isWide,
            title: const Text('Homeworks'),
            actions: [
              LoadingIconButton(
                icon: Icons.refresh,
                onTap: () async {
                  try {
                    return await firestoreService.syncHomeworks().then(
                      (value) {
                        updateListView();
                      },
                    );
                  } on Object catch (e) {
                    if (context.mounted) {
                      showMessage(context, e.toString(), isError: true);
                    }
                    return;
                  }
                },
              ),
            ],
          ),
          body: PriorityView(
            hwByPriority: hwByPriority,
            completedHws: completedHw,
            reorderHomework: reorderHomework,
            updateView: updateListView,
          ),
        );
      },
    );
  }
}
