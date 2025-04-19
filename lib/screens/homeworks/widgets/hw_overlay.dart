import 'dart:async';

import 'package:flutter/material.dart';
import 'package:school_manager/models/homeworks/hw_model.dart';
import 'package:school_manager/widgets/animated_completion.dart';

class HwOverlay extends StatefulWidget {
  const HwOverlay({
    super.key,
    required this.hw,
    required this.position,
    required this.size,
    required this.onHide,
    required this.onEdit,
    required this.onDelete,
    required this.onConvert,
  });

  final Homework hw;
  final Offset position;
  final Size size;
  final void Function() onEdit;
  final void Function()? onConvert;
  final void Function()? onDelete;
  final void Function() onHide;

  @override
  State<HwOverlay> createState() => _HwOverlayState();
}

class _HwOverlayState extends State<HwOverlay> with TickerProviderStateMixin {
  bool fullSize = false;
  static const Duration duration = Duration(milliseconds: 300);
  static const Curve curve = Curves.easeInOut;

  static const double borderRadius = 12;
  // static const double padding = 5;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        fullSize = true;
      });
    });
  }

  void close() {
    setState(() {
      fullSize = false;
    });
    Future.delayed(duration, widget.onHide);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        AnimatedContainer(
          duration: duration,
          curve: curve,
          color: fullSize
              ? const Color.fromARGB(150, 0, 0, 0)
              : Colors.transparent,
        ),
        GestureDetector(onTap: close),
        AnimatedPositioned(
          duration: duration,
          curve: curve,
          top: fullSize ? screenSize.height / 8 : widget.position.dy,
          left: fullSize ? 8 : widget.position.dx,
          child: GestureDetector(
            onTap: () {
              close();
              // widget.onEdit();
            },
            child: Material(
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: duration,
                    curve: curve,
                    width: fullSize ? screenSize.width - 16 : widget.size.width,
                    height: fullSize ? 250 : widget.size.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                    ),
                    alignment: Alignment.topLeft,
                    // padding: EdgeInsets.all(padding),
                    child: Wrap(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AnimatedCompletionTile(
                              hw: widget.hw,
                              onChangedCompletion: (p0) {},
                              onDelete: () {},
                              onEdit: () {
                                close();
                                widget.onEdit();
                              },
                              onConvert: () {},
                            ),
                            AnimatedOpacity(
                              opacity: fullSize ? 1.0 : 0,
                              duration: duration,
                              curve: curve,
                              child: Text(widget.hw.description ?? ''),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  AnimatedOpacity(
                    opacity: fullSize ? 1 : 0,
                    duration: duration,
                    curve: curve,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 8,
                      children: [
                        FilledButton.tonalIcon(
                          onPressed: () {
                            close();
                            widget.onEdit();
                          },
                          label: Text('Edit'),
                          icon: Icon(Icons.edit),
                        ),
                        if (widget.onConvert != null)
                        FilledButton.tonalIcon(
                          onPressed: () {
                            close();
                            widget.onConvert!();
                          },
                          label: Text('Convert to exam'),
                          icon: Icon(Icons.swap_vert_circle_outlined),
                        ),
                        if (widget.onDelete != null)
                        FilledButton.tonalIcon(
                          onPressed: () {
                            close();
                            widget.onDelete!();
                          },
                          label: Text('Delete'),
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
