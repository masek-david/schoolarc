import 'package:flutter/material.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/fonts.dart';

class RecapButton extends StatelessWidget {
  const RecapButton({
    super.key,
    required this.content,
    this.borderRadius = 20,
  });

  factory RecapButton.full(BuildContext context) {
    return RecapButton(
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${context.loc.anotherYearBehind} 🎉',
                  style: robotoSerif(size: 20, weight: 600, width: 50),
                ),
                Text(
                  context.loc.viewYearStats,
                  style: robotoSerif(size: 14, width: 100),
                ),
              ],
            ),
            const Icon(Icons.keyboard_arrow_right_rounded),
          ],
        ),
      ),
    );
  }
  factory RecapButton.small(BuildContext context) {
    return RecapButton(
      content: SizedBox(
        width: double.infinity,
        height: 56,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${context.loc.viewYearStats} 🎉',
                style: robotoSerif(size: 16, weight: 600, width: 50),
              ),
              const Icon(Icons.keyboard_arrow_right_rounded),
            ],
          ),
        ),
      ),
    );
  }

  final Widget content;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer,
            colors.tertiaryContainer,
          ],
        ),
      ),
      child: Material(
        borderRadius: BorderRadius.circular(borderRadius),
        clipBehavior: Clip.antiAlias,
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.restorablePushNamed(context, '/recap');
          },
          child: content,
        ),
      ),
    );
  }
}
