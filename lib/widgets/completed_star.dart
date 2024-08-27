import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CompletedStar extends StatefulWidget {
  const CompletedStar({super.key});

  @override
  State<CompletedStar> createState() => _CompletedStarState();
}

class _CompletedStarState extends State<CompletedStar>
    with TickerProviderStateMixin {
  double turns = 2 / 12;
  double scale = 1;

  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late Animation<double> scaleAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _rotationController.addListener(() => setState(() {}));
    _scaleController.addListener(() => setState(() {}));

    scaleAnimation = Tween(
      begin: 0.3,
      end: 1.0,
    ).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.fastOutSlowIn));

    _scaleController.forward();
    _rotationController.repeat(reverse: false);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(50),
      child: GestureDetector(
        onLongPressDown: (details) {
          _scaleController.animateBack(
            0.5,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCirc,
          );
        },
        onLongPressStart: (details) {
          HapticFeedback.lightImpact();
        },
        onLongPressUp: () {
          HapticFeedback.lightImpact();
          _scaleController.forward();
          setState(() {
            turns += 4 / 12;
          });
        },
        onLongPressCancel: () {
          _scaleController.forward();
          setState(() {
            turns += 1 / 12;
          });
        },
        child: Transform.scale(
          scale: scaleAnimation.value,
          child: Stack(
            children: [
              Transform.rotate(
                angle: 6.28 * _rotationController.value,
                child: AnimatedRotation(
                  turns: turns,
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  child: Container(
                    height: 180,
                    decoration: ShapeDecoration(
                      shadows: [
                        BoxShadow(
                          blurRadius: 30,
                          spreadRadius: -1,
                          color:
                              Theme.of(context).colorScheme.tertiaryContainer,
                        ),
                      ],
                      gradient: LinearGradient(colors: [
                        Theme.of(context).colorScheme.tertiaryContainer,
                        // .withAlpha(100),
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
              ),
              SizedBox(
                height: 180,
                child: Center(
                  child: Text(
                    'Everything done',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Theme.of(context).colorScheme.onPrimary,
                          blurRadius: 10,
                        )
                      ],
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
