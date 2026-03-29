import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_meals_notifier.dart';
import 'package:schoolarc/screens/main_screens/home/widgets/card_with_title.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/widgets/ago_text.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_loading_indicator.dart';
import 'package:schoolarc/widgets/expressive_loading/expressive_refresh_indicator.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';
import 'package:schoolarc/widgets/tiles/meal_tile.dart';

class MealsScreen extends ConsumerWidget {
  const MealsScreen({super.key});

  Future<void> refresh(WidgetRef ref) async {
    await ref.read(stravaMealsProvider.notifier).refresh();
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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AgoText(stream: stravaMealsAgeProvider),
          ),
        ],
      ),
      body: ExpressiveRefreshIndicator(
        onRefresh: () async {
          await refresh(ref);
        },
        child: isLoading
            ? Center(child: ExpressiveLoadingIndicator.big())
            : error != null
            ? ListView(
                children: [
                  ErrorTile(
                    error: error,
                    text: context.loc.mealsNotLoaded,
                    padding: const EdgeInsetsGeometry.all(16),
                  ),
                ],
              )
            : ListView.builder(
                itemCount: itemCount,
                itemBuilder: (context, index) {
                  if (data?.isEmpty ?? false) {
                    Center(child: Text(context.loc.noMealsFound));
                  }

                  final date = Date.today().addDays(index);

                  final mealsForToday = data?[date];
                  final bool empty = mealsForToday == null;

                  return Padding(
                    padding: const .fromLTRB(8, 0, 8, 8),
                    child: CardWithTitle(
                      highContainer: true,
                      greydOut: empty,
                      text: empty
                          ? context.loc
                                .noMealsOn(
                                  date
                                      .formatWithWeekday(
                                        context,
                                        useOnFormat: true,
                                      )
                                      .unCapitalize(),
                                )
                                .capitalize()
                          : context.loc
                                .mealsOn(
                                  date
                                      .formatWithWeekday(
                                        context,
                                        useOnFormat: true,
                                      )
                                      .unCapitalize(),
                                )
                                .capitalize(),
                      childPadding: const .fromLTRB(8, 0, 8, 8),
                      child: empty
                          ? null
                          : Column(
                              children: mealsForToday
                                  .map(
                                    (meal) => MealTile(meal: meal),
                                  )
                                  .toList(),
                            ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
