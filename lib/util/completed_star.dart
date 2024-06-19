import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompletedStar extends StatefulWidget {
  const CompletedStar({super.key});

  @override
  State<CompletedStar> createState() => _CompletedStarState();
}

class _CompletedStarState extends State<CompletedStar> {
  double turns = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          splashFactory: NoSplash.splashFactory,
          onTap: () => setState(() {
            HapticFeedback.lightImpact();
            turns += 2 / 12;
          }),
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
                      Theme.of(context).colorScheme.tertiary,
                      Theme.of(context).colorScheme.primary
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
                        color: Theme.of(context).colorScheme.onTertiary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
