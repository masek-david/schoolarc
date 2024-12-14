import 'package:flutter/material.dart';
import 'package:school_manager/services/settings_database.dart';
import 'package:school_manager/utils/extensions/datetime_extension.dart';
import 'package:school_manager/screens/calendar/widgets/text_separator.dart';
import 'package:school_manager/tasks_app.dart';
import 'package:school_manager/widgets/error_tile.dart';
import 'package:school_manager/widgets/meals/meal_tile.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({
    super.key,
  });

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  var meals = stravaService.getMeals();

  void refresh() {
    setState(() {
      meals = stravaService.getMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    var now = DateTime.now();

    if (settings
        .getTimeOfDay(Setting.mealsShowTodayUntil)
        .isBefore(TimeOfDay(hour: now.hour, minute: now.minute))) {
      now = now.toUtc().add(const Duration(days: 1)).toLocal();
    }

    final todayLocal000 = DateTime(now.year, now.month, now.day, 0, 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Meals'),
      ),
      body: FutureBuilder(
        future: meals,
        builder: (context, snapshot) {
          bool isLoading = false;

          if (snapshot.connectionState == ConnectionState.waiting) {
            isLoading = true;
          } else if (snapshot.hasError) {
            return ErrorTile(
              error: snapshot.error,
              text: 'Meals couldn\'t be loaded',
            );
          } else if (!snapshot.hasData) {
            return const Center(child: Text('No meals found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              refresh();
            },
            child: ListView.builder(
              itemCount: snapshot.data?.keys.length ?? 1,
              itemBuilder: (context, index) {
                final date =
                    todayLocal000.toUtc().add(Duration(days: index)).toLocal();

                final mealsForToday = snapshot.data?[date];
                final bool empty = mealsForToday == null;

                return Card(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextSeparator(
                          text: isLoading
                              ? 'Loading'
                              : empty
                                  ? 'No meals for ${date.dateText().toLowerCase()}'
                                  : 'Meals for ${date.dateText().toLowerCase()}',
                        ),
                        if (!empty)
                          ...mealsForToday.map((meal) {
                            return MealTile(meal: meal);
                          }),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
