import 'package:flutter/material.dart';

class RecapButton extends StatelessWidget {
  const RecapButton({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.restorablePushNamed(context, '/recap');
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
