import 'package:flutter/material.dart';
import 'package:school_manager/data/homeworks_data/hw_dto_model.dart';
import 'package:school_manager/data/priority_model.dart';
import 'package:school_manager/screens/homeworks/widgets/homework_tile.dart';

class AnimatedCompletionTile extends StatefulWidget {
  const AnimatedCompletionTile({
    super.key,
    required this.hw,
    required this.priority,
    required this.onAnimationEnd,
    required this.onChangedCompletion,
    required this.onDelete,
    required this.onEdit,
  });

  final HomeworkDTO hw;
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

  late AnimationController _controller;

  void playAnimation() {
    _controller.reset();
    _controller.animateTo(1, curve: Curves.easeInSine).then(
      (value) {
        _controller.reset();
        widget.onAnimationEnd();
      },
    );
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
      value: 0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
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
          hw: widget.hw,
          priority: widget.priority,
          onChangedCompletion: (value) {
            widget.onChangedCompletion(value);
            if (value) {
              playAnimation();
            } 
            else{
              widget.onAnimationEnd();
            }
          },
          onDelete: () => widget.onDelete,
          onEdit: () => widget.onEdit,
        ),
      ),
    );
  }
}
