import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/data/priority_model.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';

class AnimatedCompletionTile extends StatefulWidget {
  const AnimatedCompletionTile({
    super.key,
    this.showDate = true,
    required this.hw,
    required this.priority,
    required this.onAnimationEnd,
    required this.onChangedCompletion,
    required this.onDelete,
    required this.onEdit,
  });

  final HomeworkDTO hw;
  final bool showDate;
  final Priority priority;
  final Function onAnimationEnd;
  final Function onDelete;
  final Function onEdit;
  final Function(bool value) onChangedCompletion;

  @override
  State<AnimatedCompletionTile> createState() => _AnimatedCompletionTileState();
}

class _AnimatedCompletionTileState extends State<AnimatedCompletionTile>
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
    } else if(value) {
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return ShaderMask(
            blendMode: BlendMode.color,
            shaderCallback: (bounds) {
              return RadialGradient(
                colors: [
                  Colors.transparent,
                  widget.priority.color,
                  Colors.transparent,
                ],
                radius: _controller.value * 50,
                center: const Alignment(0.85, 0),
              ).createShader(bounds);
            },
            child: child,
          );
        },
        child: HomeworkTile(
          showDeadline: widget.showDate,
          hw: widget.hw,
          priority: widget.priority,
          onChangedCompletion: (value) {
            widget.onChangedCompletion(value);
            playAnimation(value);
            if (value) {
            } else {
              // widget.onAnimationEnd();
            }
          },
          onDelete: () => widget.onDelete(),
          onEdit: () => widget.onEdit(),
        ),
      ),
    );
  }
}
