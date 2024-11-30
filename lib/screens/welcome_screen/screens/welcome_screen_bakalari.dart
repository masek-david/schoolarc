import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:school_manager/screens/bakalari/bakalari_screen.dart';

class WelcomeScreenBakalari extends StatelessWidget {
  const WelcomeScreenBakalari({super.key});

  @override
  Widget build(BuildContext context) {
    return SlidableAutoCloseBehavior(
      child: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'You can log in to Bakaláři and import view your timetable:',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 50),
            const Expanded(child: BakalariScreen(showAppbar: false,))
          ],
        ),
      )),
    );
  }
}
