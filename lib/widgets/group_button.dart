import 'package:flutter/material.dart';

class GroupButton extends StatelessWidget {
  const GroupButton({
    super.key,
    required this.child,
    required this.roundedLeft,
    required this.roundedRight,
  });

  final Widget child;
  final bool roundedLeft;
  final bool roundedRight;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(4),
          right: Radius.circular(4),
        ),
      ),
      child: child,
    );
  }
}
