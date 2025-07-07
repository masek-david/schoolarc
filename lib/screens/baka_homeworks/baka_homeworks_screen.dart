import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:school_manager/models/bakalari/baka_hw_model.dart';
import 'package:school_manager/provider/baka_notifier.dart';
import 'package:school_manager/provider/exam_notifier.dart';
import 'package:school_manager/provider/hw_notifier.dart';
import 'package:school_manager/screens/baka_homeworks/baka_hw_tile.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/widgets/error_tile.dart';

class BakaHomeworksScreen extends ConsumerStatefulWidget {
  const BakaHomeworksScreen({super.key});

  @override
  ConsumerState<BakaHomeworksScreen> createState() =>
      _BakaHomeworksScreenState();
}

class _BakaHomeworksScreenState extends ConsumerState<BakaHomeworksScreen> {
  Future<List<BakaHomework>>? homeworksFuture;
  var homeworks = <BakaHomework>[];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        refresh();
      },
    );
    super.initState();
  }

  void add(BuildContext context, BakaHomework hw, bool isHomework) {
    if (isHomework) {
      ref.read(hwProvider.notifier).saveNew(
            hw
                .copyWith(timestamp: DateTime.now().toUtc(), isCompleted: false)
                .toHw(),
          );
    } else {
      ref.read(examProvider.notifier).saveNew(
            hw.copyWith(timestamp: DateTime.now().toUtc()).toExam(),
          );
    }

    bakaHomeworkService.addedHomework(hw.bakaId);

    setState(() {
      homeworks
          .firstWhere(
            (element) => element.bakaId == hw.bakaId,
          )
          .alreadyAdded = true;
    });
    final loc = context.loc;
    showMessage(context,
        '${isHomework ? loc.homeworks(1) : loc.exams(1)} ${loc.added.toLowerCase()}');
  }

  Future<void> refresh() async {
    setState(() {
      homeworksFuture = ref.read(bakaProvider.notifier).getHomeworks();
    });

    try {
      await homeworksFuture;
    } catch (_) {}

    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.hwFromBaka),
      ),
      body: FutureBuilder(
        future: homeworksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return ErrorTile(
              error: snapshot.error,
              actions: [
                IconButton(
                  onPressed: refresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            );
          } else if (!snapshot.hasData) {
            return Text(context.loc.noData);
          }

          homeworks = snapshot.data!;

          final newHw = homeworks.where((hw) => !hw.alreadySeen).toList();
          final otherHw = homeworks.where((hw) => hw.alreadySeen).toList();
          otherHw.sort((a, b) => (a.deadline.compareTo(b.deadline)));
          otherHw.sort((a, b) => (a.alreadyAdded == b.alreadyAdded
              ? 0
              : (a.alreadyAdded ? 1 : -1)));

          bool showNew = newHw.isNotEmpty;

          return ListView.builder(
            itemCount: otherHw.length + (showNew ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0 && showNew) {
                return Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16, top: 16),
                        child: Text(
                          context.loc.newHomeworks,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      ...newHw.map(
                        (hw) {
                          bakaHomeworkService.seenHomework(hw.bakaId);

                          return BakaHwTile(
                            hw: hw,
                            onSave: (isHomework, hw) =>
                                add(context, hw, isHomework),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }

              BakaHomework hw = otherHw[index - (showNew ? 1 : 0)];

              return BakaHwTile(
                hw: hw,
                onSave: (isHomework, hw) {
                  add(context, hw, isHomework);
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      ),
    );
  }
}
