import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_meals_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/widgets/ago_text.dart';
import 'package:schoolarc/widgets/buttons/loading_icon_button.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';
import 'package:schoolarc/widgets/tiles/meal_tile.dart';

class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  void refresh(WidgetRef ref) {
    ref.read(stravaMealsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meals = ref.watch(stravaMealsProvider);
    final isLoading = meals.isLoading;
    final error = meals.error;
    final data = meals.value;

    final showMealsUntil = ref.watch(mealsShowTodayUntilProvider);
    var now = DateTime.now();

    if (showMealsUntil.isBefore(
      TimeOfDay(hour: now.hour, minute: now.minute),
    )) {
      now = now.toUtc().add(const Duration(days: 1)).toLocal();
    }

    int itemCount = data?.keys.length ?? 1;
    if (itemCount == 0) {
      itemCount = 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.meals),
        actions: [
          AgoText(stream: stravaMealsAgeProvider),
          LoadingIconButton(
            icon: Icons.refresh,
            onTap: () => refresh(ref),
            isLoading: isLoading,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refresh(ref);
        },
        child: ListView.builder(
          itemCount: itemCount,
          itemBuilder: (context, index) {
            if (error != null) {
              return ErrorTile(
                error: error,
                text: context.loc.mealsNotLoaded,
              );
            }
            if (data?.isEmpty ?? false) {
              Center(child: Text(context.loc.noMealsFound));
            }

            final date = Date.today().addDays(index);

            final mealsForToday = data?[date];
            final bool empty = mealsForToday == null;

            return Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          isLoading
                              ? context.loc.loading
                              : empty
                                  ? '${context.loc.noMealsFor} ${date.formatFromSettings().toLowerCase()}'
                                  : '${context.loc.mealsFor} ${date.formatFromSettings().toLowerCase()}',
                          style: context.txt.bodyLarge,
                        )),
                    if (!empty)
                      ...mealsForToday.map(
                        (meal) => MealTile(meal: meal),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
