import 'package:flutter/material.dart';
import 'package:school_manager/models/priority_model.dart';

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
          const Text('This is how the app will look with these colors:'),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                  onPressed: () {}, child: const Text('Filled Button')),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                ),
                child: const Text('Filled Button'),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Choice chip'),
                selected: true,
                onSelected: (value) {},
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Choice chip'),
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
