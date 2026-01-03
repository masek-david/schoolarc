import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:schoolarc/screens/tutorial/animated_page.dart';
import 'package:schoolarc/screens/tutorial/tutorial.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/tiles/hw_tile.dart';

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

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _controller.openTo(-0.3);
      }
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
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
                if (value) {
                  showMessage(context, context.loc.tutorialCompleteHomework);
                }
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
        AnimatedItem(
          builder: (isShown) => Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Text(context.loc.tutorialSlideToDelete),
          ),
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
