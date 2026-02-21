import 'dart:math';

import 'package:flutter/material.dart';
import 'package:m3_expressive_shapes/rounded_polygon_border.dart';
import 'package:m3_expressive_shapes/shapes/material_shapes.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class OnboardingEnd extends StatefulWidget {
  const OnboardingEnd({
    super.key,
    required this.onEnd,
    required this.makeTransparent,
  });

  final void Function() onEnd;
  final void Function() makeTransparent;

  @override
  State<OnboardingEnd> createState() => _OnboardingEndState();
}

class _OnboardingEndState extends State<OnboardingEnd>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> innerGradient;
  late final Animation<double> outerGradient;
  late final Animation<double> opacityAnimation;
  late final Animation<double> morphAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    innerGradient = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 1, curve: Curves.decelerate),
      ),
    );
    outerGradient = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 1, curve: Curves.decelerate),
      ),
    );
    opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.2, curve: Curves.linear),
      ),
    );
    morphAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void animate() {
    if (_controller.isAnimating) {
      return;
    }

    widget.makeTransparent();
    _controller.animateTo(1).then(
      (value) {
        _controller.reset();
        widget.onEnd();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primaryContainer;
    final background = Theme.of(context).colorScheme.surface;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: .center,
          children: [
            ShaderMask(
              shaderCallback: (Rect bounds) {
                final height = bounds.size.height;
                final width = bounds.size.width;

                return RadialGradient(
                  // the gradient fills the whole screen, including corners
                  radius: 0.5 * (max(height, width) / min(height, width)) + 0.2,
                  colors: const <Color>[Colors.transparent, Colors.white],
                  stops: [innerGradient.value, outerGradient.value],
                ).createShader(bounds);
              },
              child: Stack(
                alignment: .center,
                children: [
                  Container(
                    height: .infinity,
                    width: .infinity,
                    color: background,
                  ),
                  Transform.scale(
                    scale: (morphAnimation.value + 0.5) * 2,
                    child: Transform.rotate(
                      angle: morphAnimation.value * pi,
                      child: GestureDetector(
                        onTap: animate,
                        child: Container(
                          decoration: ShapeDecoration(
                            shape: ShapeBorder.lerp(
                              RoundedPolygonBorder(
                                polygon: MaterialShapes.square,
                              ),
                              RoundedPolygonBorder(
                                polygon: MaterialShapes.cookie7,
                              ),
                              morphAnimation.value,
                            )!,
                            color: color,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Opacity(
                            opacity: opacityAnimation.value,
                            child: Icon(
                              Icons.keyboard_arrow_right_rounded,
                              size: 56,
                              color: context.col.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: opacityAnimation.value,
              child: SizedBox(
                width: .infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.loc.setupComplete,
                      style: context.txt.headlineMedium,
                    ),
                    Text(
                      context.loc.continueToApp,
                      style: context.txt.bodyLarge,
                    ),
                    const SizedBox(height: 220),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
