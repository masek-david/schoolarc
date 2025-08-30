import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class CircularWavyLoadingIndicator extends StatefulWidget {
  const CircularWavyLoadingIndicator({
    super.key,
    this.activeColor,
    this.inactiveColor,
    this.strokeWidth = 8,
    this.wavelength = 18,
    this.amplitude = 2,
    this.size,
  });

  final double amplitude;
  final double strokeWidth;
  final double wavelength;
  final double? size;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  State<CircularWavyLoadingIndicator> createState() =>
      _CircularWavyLoadingIndicatorState();
}

class _CircularWavyLoadingIndicatorState
    extends State<CircularWavyLoadingIndicator> with TickerProviderStateMixin {
  late final _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  );
  late final _progressController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
    value: 0.1,
  );
  double rotation = 0;

  @override
  void initState() {
    super.initState();
    _rotationController.repeat();
    loop();
  }

  void loop() async {
    while (mounted) {
      if (mounted) {
        await _progressController.animateTo(0.75, curve: Curves.easeOutSine);
      }
      await Future.delayed(const Duration(milliseconds: 500));
      rotation += 0.25;
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await _progressController.animateTo(0.1, curve: Curves.easeOutSine);
      }
      await Future.delayed(const Duration(milliseconds: 500));
      rotation += 0.25;
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, _) {
        return Transform.rotate(
            angle: _rotationController.value * 2 * pi,
            child: AnimatedRotation(
              duration: const Duration(milliseconds: 500),
              turns: rotation,
              curve: Curves.decelerate,
              child: CustomPaint(
                size: Size(widget.size ?? 44 + widget.strokeWidth,
                    widget.size ?? 44 + widget.strokeWidth),
                painter: _WavyLinearProgressIndicatorPainter(
                  amplitude: widget.amplitude,
                  wavelength: widget.wavelength,
                  strokeWidth: widget.strokeWidth,
                  activeColor: widget.activeColor ?? context.col.primary,
                  inactiveColor:
                      widget.inactiveColor ?? context.col.secondaryContainer,
                  faze: -0.2,
                  progress: _progressController.value,
                ),
              ),
            ),
        );
      },
    );
  }
}

class CircularWavyProgressIndicator extends StatefulWidget {
  const CircularWavyProgressIndicator({
    super.key,
    required this.value,
    this.activeColor,
    this.inactiveColor,
    this.strokeWidth = 8,
    this.wavelength = 18,
    this.amplitude = 2,
    this.size,
  });

  final double value;
  final double amplitude;
  final double strokeWidth;
  final double wavelength;
  final double? size;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  State<CircularWavyProgressIndicator> createState() =>
      _CircularWavyProgressIndicatorState();
}

class _CircularWavyProgressIndicatorState
    extends State<CircularWavyProgressIndicator> with TickerProviderStateMixin {
  late final _fazeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  );
  late final _amplitudeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );

  @override
  void initState() {
    super.initState();
    _fazeController.repeat();
  }

  @override
  void dispose() {
    _fazeController.dispose();
    _amplitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.value > 0.1 && widget.value < 0.9) {
      _amplitudeController.animateTo(1);
    } else {
      _amplitudeController.animateTo(0);
    }

    return AnimatedBuilder(
      animation: _fazeController,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomPaint(
            size: Size(widget.size ?? 44 + widget.strokeWidth,
                widget.size ?? 44 + widget.strokeWidth),
            painter: _WavyLinearProgressIndicatorPainter(
              amplitude: _amplitudeController.value * widget.amplitude,
              wavelength: widget.wavelength,
              strokeWidth: widget.strokeWidth,
              activeColor: widget.activeColor ?? context.col.primary,
              inactiveColor:
                  widget.inactiveColor ?? context.col.secondaryContainer,
              // faze: 0,
              faze: _fazeController.value,
              // progress: 0.5,
              progress: widget.value,
            ),
          ),
        );
      },
    );
  }
}

class _WavyLinearProgressIndicatorPainter extends CustomPainter {
  final Color activeColor;
  final Color inactiveColor;
  final double strokeWidth;
  final double amplitude;
  final double wavelength;
  final double progress;
  final double faze;

  _WavyLinearProgressIndicatorPainter({
    required this.amplitude,
    required this.wavelength,
    required this.activeColor,
    required this.inactiveColor,
    required this.strokeWidth,
    required this.progress,
    required this.faze,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final activePath = Path();
    final inactivePath = Path();

    final yCenter = size.height / 2;
    final xCenter = size.width / 2;

    final samples = size.width * 5;
    final r = size.width / 2;
    final circumference = 2 * pi * r;
    final angleOffset = 0.1;

    for (int i = 0; i <= samples; i++) {
      final alpha = (i / samples) * 2 * pi - pi / 2;

      if (i > samples * progress + 1) {
        final test = (2 * pi - alpha - pi / 2) * r;
        if (test > 8 + 2 * strokeWidth) {
          final spacingAngle = (4 + strokeWidth) / r;
          inactivePath.addArc(
              Rect.fromCircle(
                  center: size.center(Offset.zero),
                  radius: r - strokeWidth / 2),
              alpha + spacingAngle + angleOffset,
              2 * pi - pi / 2 - alpha - 2 * spacingAngle);
        }
        break;
      }

      final rSin = r -
          amplitude -
          strokeWidth / 2 +
          amplitude *
              sin(2 * pi * (circumference * (i / samples)) / wavelength +
                  2 * pi * faze +
                  pi);
      // final rSin = r + amplitude * sin(2 * pi * (i / wavelength + faze + 0.0));

      final x = cos(alpha + angleOffset) * rSin;
      final y = sin(alpha + angleOffset) * rSin;

      if (i == 0) {
        activePath.moveTo(x + xCenter, y + yCenter);
      } else {
        activePath.lineTo(x + xCenter, y + yCenter);
      }
    }

    canvas.drawPath(activePath, activePaint);
    canvas.drawPath(inactivePath, inactivePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
