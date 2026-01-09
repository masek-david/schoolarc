import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_meals_notifier.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/extensions/date_extension.dart';
import 'package:schoolarc/utils/extensions/string_extension.dart';
import 'package:schoolarc/utils/fonts.dart';
import 'package:schoolarc/utils/globals.dart';
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
    final isVisible = ref.watch(useMealsProvider);
    if(!isVisible) return const SizedBox.shrink();

    final meals = ref.watch(stravaMealsProvider);
    final isLoading = meals.isLoading;
    final error = meals.error;
    // Dont show the data if there is error
    final data = error == null ? meals.value : null;

    final showMealsUntil = ref.watch(mealsShowTodayUntilProvider);

    var firstDay = Date.today();
    if (showMealsUntil.isBefore(TimeOfDay.now())) {
      firstDay = firstDay.addDays(1);
    }

    int pagesCount = data?.keys.length ?? 1;
    if (pagesCount == 0) {
      pagesCount = 1;
    }

    return Container(
      clipBehavior: .antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: context.col.surfaceContainerLow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExpandablePageView.builder(
            estimatedPageSize: data?[firstDay]?.isEmpty ?? true ? 55 : 280,
            animateFirstPage: false,
            controller: _pageController,
            animationDuration: const Duration(milliseconds: 250),
            itemCount: pagesCount,
            itemBuilder: (context, index) {
              final date = firstDay.addDays(index);
    
              final mealsForToday = data?[date];
              final bool empty = mealsForToday == null;
    
              String text = '';
              if (isLoading) {
                text = context.loc.loading;
              } else {
                if (empty) {
                  text = context.loc
                      .noMealsOn(
                        date
                            .formatWithWeekday(
                              context,
                              useOnFormat: true,
                            )
                            .unCapitalize(),
                      )
                      .capitalize();
                } else {
                  text = context.loc
                      .mealsOn(
                        date
                            .formatWithWeekday(
                              context,
                              useOnFormat: true,
                            )
                            .unCapitalize(),
                      )
                      .capitalize();
                }
              }
    
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: error == null
                            ? Padding(
                                padding: const EdgeInsetsGeometry.all(16),
                                child: Text(
                                  text,
                                  style: googleSansFlex(
                                    size: 16,
                                    weight: 500,
                                    color: empty
                                        ? getSubtleTextColor(context)
                                        : null,
                                  ),
                                ),
                              )
                            : ErrorTile(
                                padding: const .all(12),
                                error: error,
                                text: context.loc.mealsNotLoaded,
                              ),
                      ),
                      LoadingIconButton(
                        onPressed: refresh,
                        isLoading: isLoading,
                      ),
                      IconButton(
                        onPressed: () {
                          ref
                              .read(stravaMealsProvider.notifier)
                              .refreshIfOld();
                          Navigator.restorablePushNamed(
                            context,
                            '/meals',
                          );
                        },
                        icon: const Icon(
                          Icons.keyboard_arrow_right_rounded,
                        ),
                      ),
                    ],
                  ),
                  if (!empty)
                    ...mealsForToday.map((meal) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: MealTile(meal: meal),
                      );
                    }),
                ],
              );
            },
          ),
          if (data != null && data.keys.length > 1)
            Padding(
              padding: const EdgeInsets.all(8),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: data.keys.length,
                effect: ScrollingDotsEffect(
                  activeDotColor: Theme.of(
                    context,
                  ).colorScheme.primary,
                  dotColor: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest,
                  maxVisibleDots: 7,
                  dotHeight: 4,
                  dotWidth: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
