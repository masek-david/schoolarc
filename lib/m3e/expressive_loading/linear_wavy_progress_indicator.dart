import 'dart:math';

import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class LinearWavyProgressIndicator extends StatefulWidget {
  const LinearWavyProgressIndicator({
    super.key,
    required this.value,
    this.activeColor,
    this.inactiveColor,
    this.strokeWidth = 8,
    this.wavelength = 40,
    this.amplitude = 3,
    this.forceFullWave = false,
    this.duration = const Duration(milliseconds: 1000),
  });

  final double value;
  final double amplitude;
  final double strokeWidth;
  final double wavelength;
  final Color? activeColor;
  final Color? inactiveColor;
  final Duration duration;

  /// If true, the wave wont stop when progress reaches the end
  final bool forceFullWave;

  @override
  State<LinearWavyProgressIndicator> createState() =>
      _LinearWavyProgressIndicatorState();
}

class _LinearWavyProgressIndicatorState
    extends State<LinearWavyProgressIndicator>
    with TickerProviderStateMixin {
  late final _fazeController = AnimationController(
    vsync: this,
    duration: widget.duration,
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
    if (widget.forceFullWave) {
      _amplitudeController.value = 1;
    } else {
      if (widget.value > 0.1 && widget.value < 0.9) {
        _amplitudeController.animateTo(1);
      } else {
        _amplitudeController.animateTo(0);
      }
    }

    return AnimatedBuilder(
      animation: _fazeController,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: CustomPaint(
            size: Size(
              double.infinity,
              2 * widget.amplitude + widget.strokeWidth,
            ),
            painter: _WavyLinearProgressIndicatorPainter(
              showStopper: !widget.forceFullWave,
              amplitude: _amplitudeController.value * widget.amplitude,
              wavelength: widget.wavelength,
              strokeWidth: widget.strokeWidth,
              activeColor: widget.activeColor ?? context.col.primary,
              inactiveColor:
                  widget.inactiveColor ?? context.col.secondaryContainer,
              faze: _fazeController.value,
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
  final bool showStopper;

  _WavyLinearProgressIndicatorPainter({
    required this.amplitude,
    required this.wavelength,
    required this.activeColor,
    required this.inactiveColor,
    required this.strokeWidth,
    required this.progress,
    required this.faze,
    required this.showStopper,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final stopperPaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;
    final inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final activePath = Path();
    final inactivePath = Path();
    final stopperPath = Path();

    final yCenter = size.height / 2;
    final horizontalOffset = strokeWidth / 2;

    final samples = size.width;
    final dx = (size.width - 2 * horizontalOffset) / samples;

    for (int i = 0; i <= samples; i++) {
      final x = i * dx + horizontalOffset;
      if (i > samples * progress + 1) {
        if (size.width - x > strokeWidth * 2) {
          inactivePath.moveTo(x + strokeWidth + 4, yCenter);
          inactivePath.lineTo(size.width - horizontalOffset, yCenter);
        }
        break;
      }

      final y = amplitude * sin(2 * pi * (x / wavelength + faze)) + yCenter;

      if (i == 0) {
        activePath.moveTo(x, y);
      } else {
        activePath.lineTo(x, y);
      }
    }

    stopperPath.moveTo(size.width - horizontalOffset, yCenter);
    stopperPath.relativeLineTo(0, 0);

    canvas.drawPath(activePath, activePaint);
    canvas.drawPath(inactivePath, inactivePaint);
    if (showStopper) {
      canvas.drawPath(stopperPath, stopperPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
