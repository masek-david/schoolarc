import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

enum ButtonSized { extraSmall, small, medium, large, extraLarge }

class FilledButtonExpressive extends StatefulWidget {
  const FilledButtonExpressive({
    super.key,
    this.isSquare = false,
    required this.onPressed,
    required this.child,
  });

  final void Function() onPressed;
  final bool isSquare;
  final Widget child;

  @override
  State<FilledButtonExpressive> createState() => _FilledButtonExpressiveState();
}

class _FilledButtonExpressiveState extends State<FilledButtonExpressive>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: duration);
  late var radiusAnimation =
      Tween<double>(
        begin: 20,
        end: 8,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.decelerate,
        ),
      );
  final duration = const Duration(milliseconds: 140);

  bool focused = false;

  Future<void> animateTapUp() async {
    if (_controller.value < 0.5) {
      await _controller.animateTo(
        _controller.value + 0.5,
        duration: duration * (0.5),
      );
    }
    _controller.animateTo(0);
  }

  Future<void> animateTapDown() async {
    await _controller.animateTo(1);
    vibrate.medium();
  }

  Future<void> animateTapCancel() async {
    await _controller.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: radiusAnimation,
      builder: (context, child) {
        // return InkWell(
        //   borderRadius: BorderRadius.circular(radiusAnimation.value),
        //   onHover: (hovered) {
        //     _controller.animateTo(hovered ? 0.3 : 0);
        //   },
        //   onTapDown: (details) async {
        //     await _controller.animateTo(1);
        //     vibrate.medium();
        //   },
        //   onTapUp: (details) async {
        //     if (_controller.value < 0.5) {
        //       await _controller.animateTo(
        //         _controller.value + 0.5,
        //         duration: duration * (0.5),
        //       );
        //     }
        //     _controller.animateTo(0);
        //   },
        //   onTapCancel: () {
        //     _controller.animateTo(0);
        //   },
        //   onFocusChange: (value) {
        //     setState(() {
        //       focused = value;
        //     });
        //     if (!value) {
        //       animateTapCancel();
        //     }
        //   },
        //   onTap: widget.onPressed,
        //   focusColor: Colors.transparent,
        //   splashColor: Colors.transparent,
        //
        //   // splashColor: context.col.tertiary,
        //   child: Container(
        //     decoration: BoxDecoration(
        //       color: context.col.primary,
        //       borderRadius: BorderRadiusGeometry.circular(
        //         radiusAnimation.value,
        //       ),
        //       border: focused
        //           ? Border.all(
        //               color: context.col.primary,
        //               width: 3,
        //               strokeAlign: 3,
        //             )
        //           : null,
        //     ),
        //     padding: const EdgeInsets.all(10),
        //     alignment: Alignment.center,
        //     child: DefaultTextStyle(
        //       style: googleSansFlex(
        //         color: context.col.onPrimary,
        //         weight: 700,
        //         roundness: 100,
        //       ),
        //       child: widget.child,
        //     ),
        //   ),
        // );

        return Focus(
          onFocusChange: (value) {
            setState(() {
              focused = value;
            });
            if (!value) {
              animateTapCancel();
            }
          },
          onKeyEvent: (node, event) {
            if (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space) {
              if (event is KeyDownEvent) {
                animateTapDown();
                return KeyEventResult.handled;
              }
              if (event is KeyUpEvent) {
                widget.onPressed();
                animateTapUp();
                return KeyEventResult.handled;
              }
            }
            return KeyEventResult.ignored;
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event) => _controller.animateTo(0.3),
            onExit: (event) => _controller.animateTo(0),
            child: GestureDetector(
              onTapDown: (details) => animateTapDown(),
              onTapUp: (details) => animateTapUp(),
              onTapCancel: () => animateTapCancel(),
              onTap: widget.onPressed,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadiusGeometry.circular(
                    radiusAnimation.value,
                  ),
                  border: focused
                      ? Border.all(
                          color: context.col.primary,
                          width: 3,
                          strokeAlign: 3,
                        )
                      : null,
                  color: Color.alphaBlend(
                    context.col.onPrimary.withAlpha(
                      (_controller.value * 64).toInt(),
                    ),
                    context.col.primary,
                  ),
                ),
                padding: const EdgeInsets.all(10),
                alignment: Alignment.center,
                child: DefaultTextStyle(
                  style: context.txt.labelLarge!.copyWith(
                    color: context.col.onPrimary,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
