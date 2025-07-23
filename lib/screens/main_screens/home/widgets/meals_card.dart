import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/meal_model.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/screens/current_timetable/loading_icon_button.dart';
import 'package:schoolarc/screens/main_screens/calendar/widgets/text_separator.dart';
import 'package:schoolarc/screens/meals/meals_screen.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/datetime_extension.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/widgets/error_tile.dart';
import 'package:schoolarc/widgets/meals/meal_tile.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MealsCard extends ConsumerStatefulWidget {
  const MealsCard({
    super.key,
    required this.meals,
    required this.refresh,
  });

  final Future<Map<DateTime, List<Meal>>>? meals;
  final Future<void> Function() refresh;

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

  @override
  Widget build(BuildContext context) {
    final isVisible = ref.watch(useMealsProvider);
    final showMealsUntil = ref.watch(mealsShowTodayUntilProvider);

    var now = DateTime.now();

    if (showMealsUntil.isBefore(
      TimeOfDay(hour: now.hour, minute: now.minute),
    )) {
      now = now.toUtc().add(const Duration(days: 1)).toLocal();
    }

    final todayLocal000 = DateTime(now.year, now.month, now.day, 0, 0);

    return AnimatedSize(
      duration: Durations.medium1,
      child: SizedBox(
        height: isVisible ? null : 0,
        child: FutureBuilder(
          future: widget.meals,
          builder: (context, snapshot) {
            bool isLoading = false;

            if (snapshot.connectionState == ConnectionState.waiting) {
              isLoading = true;
            } else if (snapshot.hasError) {
              return ErrorTile(
                error: snapshot.error,
                text: context.loc.mealsNotLoaded,
                actions: [
                  LoadingIconButton(
                    icon: Icons.refresh,
                    onTap: () => widget.refresh(),
                    isLoading: isLoading,
                  ),
                  IconButton(
                    onPressed: () {
                      pushScreen(context, const MealsScreen());
                    },
                    icon: const Icon(Icons.keyboard_arrow_right_rounded),
                  ),
                ],
              );
            } else if (!snapshot.hasData) {
              return Center(child: Text(context.loc.noMealsFound));
            }

            int pagesCount = snapshot.data?.keys.length ?? 1;
            if (pagesCount == 0) {
              pagesCount = 1;
            }

            return Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ExpandablePageView.builder(
                    animateFirstPage: true,
                    controller: _pageController,
                    animationDuration: Durations.medium2,
                    itemCount: pagesCount,
                    itemBuilder: (context, index) {
                      final date = todayLocal000
                          .toUtc()
                          .add(Duration(days: index))
                          .toLocal();

                      final mealsForToday = snapshot.data?[date];
                      final bool empty = mealsForToday == null;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextSeparator(
                              text: isLoading
                                  ? context.loc.loading
                                  : empty
                                      ? '${context.loc.noMealsFor} ${date.dayOfWeekText().toLowerCase()}'
                                      : '${context.loc.mealsFor} ${date.dayOfWeekText().toLowerCase()}',
                              actions: [
                                LoadingIconButton(
                                  icon: Icons.refresh,
                                  onTap: () => widget.refresh(),
                                  isLoading: isLoading,
                                ),
                                IconButton(
                                  onPressed: () {
                                    pushScreen(context, const MealsScreen());
                                  },
                                  icon: const Icon(
                                      Icons.keyboard_arrow_right_rounded),
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
                  if (snapshot.data?.keys.length != null)
                    if (snapshot.data!.keys.length > 1)
                      SmoothPageIndicator(
                        controller: _pageController,
                        count: snapshot.data?.keys.length ?? 0,
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
                  const SizedBox(height: 5),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
