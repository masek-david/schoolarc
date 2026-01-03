import 'package:flutter/material.dart';
import 'package:schoolarc/models/meal_model.dart';
import 'package:schoolarc/utils/fonts.dart';

class MealTile extends StatelessWidget {
  const MealTile({
    super.key,
    required this.meal,
    this.compact = false,
  });

  final Meal meal;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: meal.selected == true
            ? Theme.of(context).colorScheme.tertiaryContainer
            : null,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            meal.type,
            style: googleSansFlex(
              size: 18,
              weight: 600,
              roundness: 100,
              width: 40,
            ),
          ),
          Text(
            meal.name,
            style: googleSansFlex(size: 14),
          ),
        ],
      ),
    );
  }
}
