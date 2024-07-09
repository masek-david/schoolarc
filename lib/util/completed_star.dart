import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompletedStar extends StatefulWidget {
  const CompletedStar({super.key});

  @override
  State<CompletedStar> createState() => _CompletedStarState();
}

class _CompletedStarState extends State<CompletedStar> {
  double turns = 2/12;
  double scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        HapticFeedback.lightImpact();
        turns += 2 / 12;
        scale = 0.97;
      }),
      child: AnimatedScale(
        scale: scale,
        onEnd: () => setState(() {
          scale = 1;
        }),
        curve: Curves.easeOut,
        duration: const Duration(milliseconds: 150),
        child: Stack(
          children: [
            AnimatedRotation(
              turns: turns,
              duration: const Duration(milliseconds: 800),
              curve: Curves.fastEaseInToSlowEaseOut,
              child: Container(
                height: 150,
                decoration: ShapeDecoration(
                  gradient: LinearGradient(colors: [
                    Theme.of(context).colorScheme.tertiaryContainer,
                    Theme.of(context).colorScheme.primaryContainer,
                  ]),
                  shape: const StarBorder(
                    points: 12.00,
                    rotation: 0.00,
                    innerRadiusRatio: 0.85,
                    pointRounding: 0.50,
                    valleyRounding: 0.50,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 150,
              child: Center(
                child: Text(
                  'Everything done',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                  maxLines: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
