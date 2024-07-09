import 'package:flutter/material.dart';

class ExpansionTitle extends StatelessWidget {
  const ExpansionTitle({
    super.key,
    required this.titleText,
    required this.titleTextColor,
    required this.numberOfItems,
  });

  final String titleText;
  final Color titleTextColor;
  final int numberOfItems;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          titleText,
          style: TextStyle(
            color: titleTextColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        // indicator of number of hw
        Container(
          height: 22,
          width: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            // color: Theme.of(context).colorScheme.primary.withAlpha(10),
            color: titleTextColor.withAlpha(25),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(numberOfItems.toString()),
          // child: Text(numberOfItems.toString(), style: TextStyle(color: titleTextColor),),
        ),
      ],
    );
  }
}
