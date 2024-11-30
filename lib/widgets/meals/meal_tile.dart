import 'package:flutter/material.dart';
import 'package:school_manager/models/meal_model.dart';

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
        borderRadius: BorderRadius.circular(12)
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            meal.type,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(meal.name),
        ],
      ),
    );
  }
}
