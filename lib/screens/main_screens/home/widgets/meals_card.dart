import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_meals_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/widgets/ago_text.dart';
import 'package:schoolarc/widgets/buttons/loading_icon_button.dart';
import 'package:schoolarc/widgets/tiles/error_tile.dart';
import 'package:schoolarc/widgets/tiles/meal_tile.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MealsCard extends ConsumerStatefulWidget {
  const MealsCard({super.key});

  @override
  ConsumerState<MealsCard> createState() => _MealsCardState();
}

class _MealsCardState extends ConsumerState<MealsCard> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void refresh() {
    ref.read(stravaMealsProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final meals = ref.watch(stravaMealsProvider);
    final isLoading = meals.isLoading;
    final error = meals.error;
    final data = meals.valueOrNull;

    final isVisible = ref.watch(useMealsProvider);
    final showMealsUntil = ref.watch(mealsShowTodayUntilProvider);

    var now = DateTime.now();

    if (showMealsUntil.isBefore(
      TimeOfDay(hour: now.hour, minute: now.minute),
    )) {
      now = now.toUtc().add(const Duration(days: 1)).toLocal();
    }

    final todayLocalDate = DateTime(now.year, now.month, now.day, 0, 0);

    int pagesCount = data?.keys.length ?? 1;
    if (pagesCount == 0) {
      pagesCount = 1;
    }

    return AnimatedSize(
      duration: Durations.medium1,
      child: SizedBox(
        height: isVisible ? null : 0,
        child: Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExpandablePageView.builder(
                animateFirstPage: true,
                controller: _pageController,
                animationDuration: Durations.medium2,
                itemCount: pagesCount,
                itemBuilder: (context, index) {
                  final date = todayLocalDate
                      .toUtc()
                      .add(Duration(days: index))
                      .toLocal();

                  final mealsForToday = data?[date];
                  final bool empty = mealsForToday == null;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Row(
                            children: [
                              if (isLoading && error == null)
                                Expanded(
                                  child: Text(
                                    context.loc.loading,
                                    style: context.txt.bodyLarge,
                                  ),
                                ),
                              if (!isLoading && error == null)
                                Expanded(
                                  child: Text(
                                    empty
                                        ? '${context.loc.noMealsFor} ${date.dayOfWeekText().toLowerCase()}'
                                        : '${context.loc.mealsFor} ${date.dayOfWeekText().toLowerCase()}',
                                    style: context.txt.bodyLarge,
                                  ),
                                ),
                              if (error != null)
                                Expanded(
                                  child: ErrorTile(
                                    contentPadding: const EdgeInsets.all(0),
                                    error: error,
                                    text: context.loc.mealsNotLoaded,
                                  ),
                                ),
                              LoadingIconButton(
                                icon: Icons.refresh,
                                onTap: refresh,
                                isLoading: isLoading,
                              ),
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(stravaMealsProvider.notifier)
                                      .refreshIfOld();
                                  Navigator.restorablePushNamed(
                                      context, '/meals');
                                },
                                icon: const Icon(
                                  Icons.keyboard_arrow_right_rounded,
                                ),
                              ),
                            ],
                          ),
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
              Stack(
                alignment: Alignment.center,
                children: [
                  if (data != null)
                    if (data.keys.length > 1)
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: data.keys.length,
                        effect: ScrollingDotsEffect(
                          activeDotColor:
                              Theme.of(context).colorScheme.tertiary,
                          dotColor: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          maxVisibleDots: 7,
                          dotHeight: 4,
                          dotWidth: 16,
                        ),
                      ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4, right: 12),
                    child: AgoText(stream: stravaMealsAgeProvider),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
