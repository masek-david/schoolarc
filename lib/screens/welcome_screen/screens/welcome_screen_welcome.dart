import 'package:flutter/material.dart';
import 'package:school_manager/widgets/animated_star.dart';

class WelcomeScreenWelcome extends StatelessWidget {
  const WelcomeScreenWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        Positioned(
          right: -120,
          top: -30,
          child: Opacity(
            opacity: isDark ? 0.3 : 1,
            child: const AnimatedStar(
              text: '',
              reactive: false,
              secondsForOneRotation: -50,
            ),
          ),
        ),
        Positioned(
          left: -360,
          bottom: -360,
          child: Opacity(
            opacity: isDark ? 0.6 : 1,
            child: const AnimatedStar(
              size: 500,
              reactive: false,
              secondsForOneRotation: 80,
              text: '',
            ),
          ),
        ),
        Positioned(
          left: 40,
          top: 150,
          child: Text(
            'Welcome',
            style: TextStyle(
              fontSize: 40,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Positioned(
          top: 240,
          left: 40,
          right: 20,
          child: Text(
            'Thanks for downloading this app. This is a tutorial for using the app. It will always be avaible to view later in the app.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }
}
