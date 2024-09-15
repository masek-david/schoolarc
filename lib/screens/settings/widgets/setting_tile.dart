import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  const SettingTile({
    super.key,
    required this.label,
    this.text,
    this.icon,
    this.action,
    this.onTap,
    this.highlighted = false,
  });

  final String label;
  final String? text;
  final Icon? icon;
  final Widget? action;
  final Function()? onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: highlighted == true ? const EdgeInsets.all(16) : null,
        margin: const EdgeInsets.all(16),
        decoration: highlighted == true
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                color: Theme.of(context).colorScheme.primary.withAlpha(100))
            : null,
        child: Row(
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: icon,
              ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 20),
                  ),
                  if (text != null)
                    Text(
                      text!,
                      maxLines: 2,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withAlpha(180),
                      ),
                    ),
                ],
              ),
            ),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}
