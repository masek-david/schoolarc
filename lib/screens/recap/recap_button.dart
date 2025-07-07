
import 'package:flutter/material.dart';
import 'package:school_manager/screens/recap/recap_screen.dart';
import 'package:school_manager/tasks_app.dart';

class RecapButton extends StatelessWidget {
  const RecapButton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: () {
          navigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (context) => const RecapScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                colors.primaryContainer,
                colors.tertiaryContainer,
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
