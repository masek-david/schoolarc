import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedStar extends StatefulWidget {
  const AnimatedStar({
    super.key,
    this.size = 180,
    this.text = 'Everything done',
    this.firstColor,
    this.secondColor,
    this.textColor,
  });

  AnimatedStar.error({
    super.key,
    this.size = 180,
    this.text = 'Error',
    required ColorScheme scheme,
  })  : firstColor = scheme.errorContainer,
        secondColor = scheme.error,
        textColor = scheme.onErrorContainer;

  AnimatedStar.success({
    super.key,
    this.size = 180,
    this.text = 'Success',
    required Color primary,
    required bool isDark,
  })  : firstColor = isDark
            ? const Color.fromARGB(255, 0, 107, 30).harmonizeWith(primary)
            : const Color.fromARGB(255, 215, 255, 212).harmonizeWith(primary),
        secondColor = isDark
            ? const Color.fromARGB(255, 193, 255, 225).harmonizeWith(primary)
            : const Color.fromARGB(255, 0, 255, 51).harmonizeWith(primary),
        textColor = isDark
            ? const Color.fromARGB(255, 220, 255, 210).harmonizeWith(primary)
            : const Color.fromARGB(255, 0, 54, 3).harmonizeWith(primary);

  final int size;
  final Color? firstColor;
  final Color? secondColor;
  final Color? textColor;
  final String text;

  @override
  State<AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<AnimatedStar>
    with TickerProviderStateMixin {
  double turns = 2 / 12;
  double scale = 1;

  late final int size = widget.size;
  late final String text = widget.text;
  late final Color firstColor =
      widget.firstColor ?? Theme.of(context).colorScheme.primaryContainer;
  late final Color secondColor =
      widget.secondColor ?? Theme.of(context).colorScheme.tertiaryContainer;
  late final Color textColor =
      widget.textColor ?? Theme.of(context).colorScheme.onTertiaryContainer;

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
    return Padding(
      padding: EdgeInsets.all(size * 0.3),
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
                    height: size.toDouble(),
                    decoration: ShapeDecoration(
                      shadows: [
                        BoxShadow(
                          blurRadius: 30,
                          spreadRadius: -1,
                          color: secondColor,
                        ),
                      ],
                      gradient:
                          LinearGradient(colors: [secondColor, firstColor]),
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
                height: size.toDouble(),
                child: Center(
                  child: Text(
                    text,
                    maxLines: 2,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: firstColor,
                          blurRadius: 10,
                        )
                      ],
                    ),
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
