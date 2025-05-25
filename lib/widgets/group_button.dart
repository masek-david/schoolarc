import 'package:flutter/material.dart';

const myCurve = Cubic(.46, -0.51, .37, -0.51);

class GroupButton extends StatefulWidget {
  const GroupButton({
    super.key,
    required this.roundedLeft,
    required this.roundedRight,
    required this.selected,
    required this.onSelected,
    this.selectedColor,
    this.backgroundColor,
    required this.child,
    required this.flex,
    required this.onTapDown,
    required this.onTapCancel,
  });

  final bool roundedLeft;
  final bool roundedRight;
  final bool selected;
  final void Function() onSelected;
  final void Function() onTapDown;
  final void Function() onTapCancel;
  final Color? selectedColor;
  final Color? backgroundColor;
  final double flex;
  final Widget child;

  @override
  State<GroupButton> createState() => _GroupButtonState();
}

class _GroupButtonState extends State<GroupButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _radiusAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: Durations.medium2);
    _radiusAnimation = Tween<double>(begin: 8, end: 20).animate(
      CurvedAnimation(
        parent: _controller,
        curve: myCurve,
        reverseCurve: Curves.decelerate,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant GroupButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selected != widget.selected) {
      if (widget.selected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color =
        widget.selected ? widget.selectedColor : widget.backgroundColor;

    return Flexible(
      flex: 1000 + (widget.flex * 100).round(),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final border = BorderRadius.horizontal(
            left: Radius.circular(
                widget.roundedLeft ? 20 : _radiusAnimation.value),
            right: Radius.circular(
                widget.roundedRight ? 20 : _radiusAnimation.value),
          );

          return Container(
            decoration: BoxDecoration(color: color, borderRadius: border),
            child: ClipRRect(
              borderRadius: border,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  splashFactory: InkSparkle.splashFactory,
                  onTapDown: (details) {
                    if (!widget.selected) {
                      widget.onTapDown();
                      _controller.animateTo(0.35);
                    }
                  },
                  onTapCancel: () {
                    if (!widget.selected) {
                      widget.onTapCancel();
                      _controller.animateBack(0);
                    }
                  },
                  onTap: widget.onSelected,
                  child: child,
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
