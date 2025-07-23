import 'package:flutter/material.dart';
import 'package:schoolarc/screens/recap/recap_screen.dart';
import 'package:schoolarc/utils/globals.dart';

class RecapButton extends StatelessWidget {
  const RecapButton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: () {
          pushScreen(context, const RecapScreen());
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
