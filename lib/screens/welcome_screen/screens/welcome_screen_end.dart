import 'package:flutter/material.dart';

class WelcomeScreenEnd extends StatefulWidget {
  const WelcomeScreenEnd({super.key, required this.onEnd});

  final void Function() onEnd;

  @override
  State<WelcomeScreenEnd> createState() => _WelcomeScreenEndState();
}

class _WelcomeScreenEndState extends State<WelcomeScreenEnd>
    with TickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
      value: 0,
    );
  }

  void animate() {
    controller.animateTo(1, curve: Curves.easeInExpo).then(
      (value) {
        widget.onEnd();
        controller.reset();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final background = Theme.of(context).colorScheme.surface;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              radius: controller.value * 100,
              colors: [
                Colors.transparent,
                color,
                color,
                color,
                background,
              ],
            ),
          ),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeIn,
            scale: controller.isAnimating ? 8 : 1,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeIn,
              opacity: controller.isAnimating ? 0 : 1,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: animate,
                      child: const Text('Go to app'),
                    ),
                    // FilledButton(
                    //   onPressed: () {
                    //     navigatorKey.currentState?.push(
                    //       MaterialPageRoute(
                    //         builder: (context) => WelcomeScreen(),
                    //       ),
                    //     );
                    //   },
                    //   child: Text('show tutorial'),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
