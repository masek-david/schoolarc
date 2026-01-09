import 'package:flutter/material.dart';

class MyDrawerButton extends StatelessWidget {
  const MyDrawerButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
    this.showBadge = false,
  });

  final String text;
  final Icon icon;
  final void Function() onTap;
  final bool showBadge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 56,
        child: TextButton(
          onPressed: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 4),
              icon,
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
              if (showBadge)
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1000),
                    color: Colors.red,
                  ),
                  height: 8,
                  width: 8,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
