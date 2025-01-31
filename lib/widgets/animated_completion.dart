import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/models/homeworks/hw_dto_model.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';

class AnimatedCompletionTile extends StatefulWidget {
  const AnimatedCompletionTile({
    super.key,
    this.showDate = true,
    this.draggable = false,
    required this.hw,
    this.slidableController,
    required this.onAnimationEnd,
    required this.onChangedCompletion,
    required this.onDelete,
    required this.onEdit,
  });

  final HomeworkDTO hw;
  final bool showDate;
  final bool draggable;
  final SlidableController? slidableController;
  final Function onAnimationEnd;
  final Function onDelete;
  final Function onEdit;
  final Function(bool value) onChangedCompletion;

  @override
  State<AnimatedCompletionTile> createState() => AnimatedCompletionTileState();
}

class AnimatedCompletionTileState extends State<AnimatedCompletionTile>
    with TickerProviderStateMixin {
  bool checkboxValue = false;
  int _lastVibrationTime = DateTime.now().millisecondsSinceEpoch;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      reverseDuration: const Duration(milliseconds: 600),
      value: 0,
    )..addListener(() {
        // Get the current timestamp
        final int currentTime = DateTime.now().millisecondsSinceEpoch;

        if (_controller.value > 0.6 || _controller.value == 0.0) {
          return;
        }
        // Check if 1000ms have passed since the last vibration
        if (currentTime - _lastVibrationTime >= _controller.value * 1000 + 20) {
          HapticFeedback.lightImpact();
          _lastVibrationTime = currentTime; // Update the last vibration time
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void playAnimation(bool value) {
    if (_controller.status == AnimationStatus.forward) {
      _controller.animateBack(0, curve: Curves.easeOutSine).then(
        (value) {
          widget.onAnimationEnd();
          _controller.reset();
        },
      );
    } else if (value) {
      _controller.animateTo(1, curve: Curves.easeInSine).then(
        (value) {
          widget.onAnimationEnd();
          _controller.reset();
        },
      );
    } else {
      widget.onAnimationEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ShaderMask(
            blendMode: BlendMode.srcOver,
            shaderCallback: (bounds) {
              final color = widget.hw.priority.getColor(context).withAlpha(200);

              return RadialGradient(
                colors: [
                  Colors.transparent,
                  color,
                  color,
                  Colors.transparent,
                ],
                radius: _controller.value * 50,
                center: Alignment(1.0 - (31 / bounds.width * 2), 0),
              ).createShader(bounds);
            },
            child: child,
          ),
        );
      },
      child: widget.draggable
          ? LayoutBuilder(
              builder: (context, constraints) {
                return LongPressDraggable(
                  data: widget.hw,
                  feedback: SizedBox(
                    width: constraints.maxWidth,
                    child: Opacity(
                      opacity: 0.6,
                      child: buildTile(),
                    ),
                  ),
                  child: buildTile(),
                );
              },
            )
          : buildTile(),
    );
  }

  Widget buildTile() {
    return HomeworkTile(
      showDeadline: widget.showDate,
      hw: widget.hw,
      slidableController: widget.slidableController,
      onChangedCompletion: (value) async { 
        widget.onChangedCompletion(value);
        playAnimation(value);
      },
      onDelete: () => widget.onDelete(),
      onTap: () => widget.onEdit(),
    );
  }
}
