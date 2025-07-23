import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/screens/tutorial/animated_page.dart';
import 'package:school_manager/screens/tutorial/tutorial.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';
import 'package:school_manager/utils/globals.dart';
import 'package:school_manager/widgets/tile/hw_tile.dart';

class TutorialInteractions extends StatefulWidget {
  const TutorialInteractions({super.key});

  @override
  State<TutorialInteractions> createState() => _TutorialInteractionsState();
}

class _TutorialInteractionsState extends State<TutorialInteractions>
    with TickerProviderStateMixin {
  late SlidableController _controller;
  bool deleted = false;
  bool completed = false;

  @override
  void initState() {
    super.initState();

    _controller = SlidableController(this);

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _controller.openTo(-0.3);
      }
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _controller.close();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPage(
      padding: const EdgeInsetsGeometry.all(16),
      spacing: 16,
      children: [
        AnimatedItem(
          builder: (isShown) => HwTile(
            hw: exampleHw(context.loc).copyWith(isCompleted: completed),
            slidableController: _controller,
            onChangedCompletion: (value) {
              if (deleted) {
                setState(() {
                  completed = value;
                });
                showMessage(context, context.loc.tutorialCompleteHomework);
              }
            },
            onDelete: () {
              setState(() {
                deleted = true;
              });
              showMessage(context, context.loc.tutorialHomeworkDelete);
            },
            onConvert: () {},
            onEdit: () {},
          ),
        ),
        AnimatedItem.spacer(height: 32),
        AnimatedItem(
          builder: (isShown) => Text(context.loc.tutorialSlideToDelete),
        ),
        AnimatedItem.spacer(height: 32),
        AnimatedItem(
          builder: (isShown) => deleted
              ? Text(context.loc.tutorialTapCheckbox)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
