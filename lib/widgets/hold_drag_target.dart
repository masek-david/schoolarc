import 'dart:async';

import 'package:flutter/material.dart';

/// A drag target that triggers [heldAction] if a draggable is held over it for a certain duration.
///
/// The [heldAction] is called repeatedly while a draggable is held over the target.
class HoldDragTarget extends StatefulWidget {
  const HoldDragTarget({
    super.key,
    required this.heldAction,
    required this.hoverStart,
    required this.builder,
    this.onAcceptWithDetails,
    this.cancelAction,
  });

  final Future<void> Function() heldAction;
  final void Function() hoverStart;
  final void Function()? cancelAction;
  final Widget Function(
    BuildContext context,
    List<Object?> candidateData,
    List<dynamic> rejectedData,
  )
  builder;
  final void Function(DragTargetDetails details)? onAcceptWithDetails;

  @override
  State<HoldDragTarget> createState() => _HoldDragTargetState();
}

class _HoldDragTargetState extends State<HoldDragTarget> {
  bool isHovering = false;

  Timer? timer;

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void setTimer() {
    timer = Timer(
      const Duration(milliseconds: 1000),
      () async {
        setTimer();
        await widget.heldAction();
        widget.hoverStart();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget(
      onMove: (details) async {
        if (isHovering == false) {
          isHovering = true;
          widget.hoverStart();
        }
        if (timer?.isActive == true) return;
        setTimer();
      },
      onLeave: (data) {
        isHovering = false;
        widget.cancelAction?.call();
        timer?.cancel();
      },
      onAcceptWithDetails: (details) {
        isHovering = false;
        timer?.cancel();
        if (widget.onAcceptWithDetails != null) {
          widget.onAcceptWithDetails!(details);
        }
      },
      builder: widget.builder,
    );
  }
}
