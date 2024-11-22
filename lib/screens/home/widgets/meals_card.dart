import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:school_manager/data/stravacz/meal_model.dart';
import 'package:school_manager/extensions/datetime_extension.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/screens/strava_cz/strava_settings_screen.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/meals/meal_tile.dart';

class MealsCard extends StatelessWidget {
  const MealsCard({
    super.key,
    required this.meals,
    required this.refresh,
  });

  final Future<Map<DateTime, List<Meal>>> meals;
  final void Function() refresh;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayLocal000 = DateTime(now.year, now.month, now.day, 0, 0);

    return FutureBuilder(
      future: meals,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child:
                Text('There was an error getting the meals: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text('No meals found'));
        }
        return Card(
          child: ExpandablePageView.builder(
            animateFirstPage: true,
            animationDuration: Durations.medium2,
            itemCount: snapshot.data?.keys.length ?? 0,
            itemBuilder: (context, index) {
              final date =
                  todayLocal000.toUtc().add(Duration(days: index)).toLocal();

              final mealsForToday = snapshot.data![date];
              final bool empty = mealsForToday == null;

              return Padding(
                padding: EdgeInsets.all(empty ? 20 : 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextSeparator(
                      text: empty
                          ? 'No meals for ${date.formattedDate()}'
                          : date.formattedDate(),
                      actions: [
                        IconButton(
                          onPressed: () {
                            refresh();
                          },
                          icon: const Icon(
                            Icons.refresh,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            navigatorKey.currentState?.push(MaterialPageRoute(
                              builder: (context) =>
                                  const StravaSettingsScreen(),
                            ));
                          },
                          icon: const Icon(
                            Icons.keyboard_arrow_right_rounded,
                          ),
                        ),
                      ],
                    ),
                    if (!empty)
                      ...mealsForToday.map((meal) {
                        return MealTile(meal: meal);
                      }),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
