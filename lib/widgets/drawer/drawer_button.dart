import 'package:flutter/material.dart';

class MyDrawerButton extends StatelessWidget {
  const MyDrawerButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onTap,
  });

  final String text;
  final Icon icon;
  final void Function() onTap;

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
              Text(text),
            ],
          ),
        ),
      ),
    );
  }
}
