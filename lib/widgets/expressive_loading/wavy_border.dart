import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';

class WavyBorder extends StatelessWidget {
  const WavyBorder({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(200, 200),
      painter: _WavyLinePainter(
        waveHeight: 10,
        strokeWidth: 8,
        waveColor: context.col.primary,
        waveWidth: 20,
      ),
    );
  }
}

class _WavyLinePainter extends CustomPainter {
  final Color waveColor;
  final double strokeWidth;
  final double waveHeight;
  final double waveWidth;

  _WavyLinePainter({
    required this.waveHeight,
    required this.waveWidth,
    required this.waveColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = waveColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    final path = Path();

    path.moveTo(strokeWidth / 2, size.height / 2 + 5);
    bool up = true;

    // for (double x = 9; x < size.width; x += waveWidth) {
      // if (up) {
        path.relativeQuadraticBezierTo(
          waveWidth / 2,
          -waveHeight,
          waveWidth,
          0,
        );
      // } else {
      // path.quadraticBezierTo(x1, y1, x2, y2)
      
        path.relativeQuadraticBezierTo(
          waveWidth / 2,
          waveHeight,
          waveWidth - 3,
          0 + 3,
        );
      // }
      up = !up;
    // }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
