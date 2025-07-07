import 'package:flutter/material.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/utils/extensions/context_extension.dart';

class ThemeColorsShowcase extends StatelessWidget {
  const ThemeColorsShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final priorities = List.generate(
      4,
      (index) {
        return TaskPriority(index);
      },
    );

    return Card(
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(context.loc.colorShowcaseTitle),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                  onPressed: () {}, child: Text(context.loc.filledButton)),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
                child: Text(context.loc.filledButton),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: Text(context.loc.choiceChip),
                selected: true,
                onSelected: (value) {},
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: Text(context.loc.choiceChip),
                selected: false,
                onSelected: (value) {},
              ),
            ],
          ),
          FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.circle_outlined),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            children: priorities.map(
              (e) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: e.getContainerColor(context),
                  ),
                  child: Text(
                    e.name,
                    style: TextStyle(
                      color: e.getOnContainerColor(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ],
      ),
    );
  }
}
