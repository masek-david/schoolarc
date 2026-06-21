import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schoolarc/m3e/m3e_parameters.dart';
import 'package:schoolarc/widgets/dialogs/predictive_back_builder.dart';

class MyBottomSheetRoute<T> extends PageRoute<T> {
  MyBottomSheetRoute({
    required this.builder,
    bool barrierDismissible = true,
  }) : _barrierDismissible = barrierDismissible;

  final WidgetBuilder builder;
  final bool _barrierDismissible;

  @override
  Duration get transitionDuration => SpatialMotion.defaultMotion.duration;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Color get barrierColor => Colors.black54;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _BottomSheetView(
      animation: animation,
      builder: builder,
    );
  }
}

class _BottomSheetView extends StatefulWidget {
  const _BottomSheetView({
    required this.animation,
    required this.builder,
  });

  final Animation<double> animation;
  final WidgetBuilder builder;

  @override
  State<_BottomSheetView> createState() => _BottomSheetViewState();
}

class _BottomSheetViewState extends State<_BottomSheetView> {
  double _dragOffset = 0;

  /// the hashcode of the last gesture that has been already popped
  /// this fixes the bug where if the route wasnt popped, it would try to show commit again
  int? _lastDismissedGesture;

  void tryPop() {
    final canPop = ModalRoute.of(context)?.popDisposition == .pop;
    Navigator.maybePop(context);

    if (!canPop && _dragOffset != 0) {
      setState(() {
        _dragOffset = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets;

    // TODO test on device not supporting predictive back
    return PredictiveBackGestureBuilder(
      transitionBuilder: (context, phase, startBackEvent, currentBackEvent, _, child) {
        // it will be true when the dialog is shown - it will force the bottom sheet to cancel the animation
        bool overrideGestureEnd = false;

        // check if we are in a gesture which hasnt been already dismissed
        if (_lastDismissedGesture != startBackEvent.hashCode) {
          // we are in a new gesture, so reset _last dismissed
          _lastDismissedGesture = null;

          if (phase == .commit) {
            // commit, so set the _lastDismissed as this gesture and try popping
            _lastDismissedGesture = startBackEvent.hashCode;
            tryPop();
          }
        } else {
          // this gesture has been already dismissed - it fires commit again (idk why)
          // we use this to override the gesture end (only if the modalroute should pop)
          final canPop = ModalRoute.of(context)?.popDisposition == .pop;

          if (phase == .commit && !canPop) {
            overrideGestureEnd = true;
          }
        }

        final progress = currentBackEvent?.progress ?? 0;
        final scale = 0.9 + 0.1 * pow(1 - progress, 2);

        return Stack(
          alignment: .bottomCenter,
          children: [
            Positioned.fill(
              child: GestureDetector(onTap: () => tryPop()),
            ),
            Transform.scale(
              alignment: .bottomCenter,
              scale: overrideGestureEnd ? 1 : scale,
              child: AnimatedBuilder(
                animation: widget.animation,
                builder: (context, _) {
                  double curvedAnimationValue;
                  if (widget.animation.isForwardOrCompleted) {
                    curvedAnimationValue = SpatialMotion.defaultMotion.curve
                        .transform(
                          widget.animation.value,
                        );
                  } else {
                    curvedAnimationValue = pow(
                      widget.animation.value,
                      6,
                    ).toDouble();
                  }

                  final yOffset =
                      // TODO the height should be computed ???
                      (1 - curvedAnimationValue) * 800 + _dragOffset;

                  return Transform.translate(
                    offset: Offset(0, yOffset),
                    child: GestureDetector(
                      onVerticalDragUpdate: (details) {
                        setState(() {
                          _dragOffset = (_dragOffset + details.delta.dy).clamp(
                            0,
                            double.infinity,
                          );
                        });
                      },
                      onVerticalDragEnd: (_) {
                        if (_dragOffset > 120) {
                          tryPop();
                        } else {
                          setState(() {
                            _dragOffset = 0;
                          });
                        }
                      },
                      child: Padding(
                        padding: EdgeInsets.only(bottom: viewInsets.bottom),
                        child: SingleChildScrollView(child: child),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
      child: widget.builder(context),
    );
  }
}
