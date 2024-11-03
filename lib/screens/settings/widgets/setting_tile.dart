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
  final IconData? icon;
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
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(icon),
                  ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        softWrap: true,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (text != null)
                        Text(
                          text!,
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
              ],
            ),
            if (action != null) action!,
          ],
        ),
      ),
    );
  }
}
