import 'package:flutter/material.dart';

class Snappable extends StatefulWidget {
  final Widget child;
  final double dragFactor; // how much of the drag to follow (0.0–1.0)

  const Snappable({
    super.key,
    required this.child,
    this.dragFactor = 0.02,
  });

  @override
  State<Snappable> createState() => _SnappableState();
}

class _SnappableState extends State<Snappable> with SingleTickerProviderStateMixin {
  Offset _offset = Offset.zero;
  late final AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addListener(() {
        setState(() {
          _offset = _animation.value;
        });
      });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _controller.stop();
    setState(() {
      _offset += details.delta * widget.dragFactor;
    });
  }

  void _onPanEnd() {
    _animation = Tween<Offset>(
      begin: _offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onPanUpdate: _onPanUpdate,
      onPanEnd: (details) => _onPanEnd(),
      onPanCancel: _onPanEnd,
      child: Transform.translate(
        offset: _offset,
        child: widget.child,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
