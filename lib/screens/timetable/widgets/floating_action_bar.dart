import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

class FloatingActionBarAction {
  const FloatingActionBarAction({required this.icon, required this.onTap});

  final IconData icon;
  final void Function() onTap;
}

class FloatingActionBar extends StatelessWidget {
  const FloatingActionBar({super.key, required this.actions});

  final List<FloatingActionBarAction> actions;

  @override
  Widget build(BuildContext context) {
    final color = context.col.secondaryContainer;
    final iconColor = context.col.onSecondaryContainer;

    return Row(
      spacing: 4,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        actions.length,
        (index) => ExpressiveIconButton(
          color: color,
          isFirst: index == 0,
          isLast: index == actions.length - 1,
          icon: Icon(actions[index].icon, color: iconColor),
          onTap: actions[index].onTap,
        ),
      ),
    );
  }
}

class ExpressiveIconButton extends StatefulWidget {
  const ExpressiveIconButton({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.color,
    required this.onTap,
    required this.icon,
  });

  final bool isFirst;
  final bool isLast;
  final Color color;
  final Widget icon;
  final void Function() onTap;

  @override
  State<ExpressiveIconButton> createState() => _ExpressiveIconButtonState();
}

class _ExpressiveIconButtonState extends State<ExpressiveIconButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        vibrate.medium();
        widget.onTap();
      },
      onTapDown: (details) {
        setState(() {
          pressed = true;
        });
      },
      onTapCancel: () {
        setState(() {
          pressed = false;
        });
      },
      onTapUp: (details) {
        setState(() {
          pressed = false;
        });
      },
      child: AnimatedContainer(
        padding: EdgeInsets.symmetric(
          vertical: 12,
          horizontal: pressed ? 14 : 12,
        ),
        duration: Durations.short2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(pressed
                ? 2
                : widget.isFirst
                    ? 30
                    : 4),
            right: Radius.circular(pressed
                ? 2
                : widget.isLast
                    ? 30
                    : 4),
          ),
          color: widget.color,
        ),
        child: widget.icon,
      ),
    );
  }
}
