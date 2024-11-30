import 'package:flutter/material.dart';
import 'package:school_manager/models/priority_model.dart';
import 'package:school_manager/utils/extensions/color_extension.dart';

class WelcomeScreenPriorities extends StatelessWidget {
  const WelcomeScreenPriorities({super.key});

  @override
  Widget build(BuildContext context) {
    late final priorities = List.generate(
      4,
      (index) => TaskPriority(index, context),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              'There are four priorities:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 50),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...priorities.map(
                  (e) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: e.color
                            .dynamicLighten(makeItLighter: Theme.of(context).brightness == Brightness.light, amount: 0.36),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: e.color,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            e.name,
                            style: TextStyle(
                              color: e.color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 50),
            const Text(
              'Every homework and exam has one priority',
            ),
          ],
        ),
      ),
    );
  }
}
