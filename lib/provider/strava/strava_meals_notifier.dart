import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/meal_model.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_login_notifier.dart';
import 'package:schoolarc/utils/globals.dart';

final stravaMealsAgeProvider = StreamProvider<Duration?>((ref) async* {
  final notifier = ref.watch(stravaMealsProvider.notifier);
  while (true) {
    final lastFetched = notifier.lastFetched;
    if (lastFetched != null) {
      yield DateTime.now().difference(lastFetched);
    } else {
      yield null;
    }
    await Future.delayed(const Duration(seconds: 1));
  }
});

final stravaMealsProvider =
    AsyncNotifierProvider<StravaMealsNotifier, Map<DateTime, List<Meal>>>(
        StravaMealsNotifier.new);

class StravaMealsNotifier extends AsyncNotifier<Map<DateTime, List<Meal>>> {
  DateTime? lastFetched;

  @override
  FutureOr<Map<DateTime, List<Meal>>> build() async {
    final useMeals = ref.watch(useMealsProvider);
    final loc = getLocalization();

    if (!useMeals) {
      throw ServiceException(loc.mealsDisabled);
    }

    final isLoggedIn = await ref.watch(stravaLoginProvider.future);

    if (!isLoggedIn) {
      throw ServiceException(
        loc.loggedOut,
        action: ExceptionActions.stravaLogin,
      );
    }

    final data = await stravaService.getMeals();
    lastFetched = DateTime.now();
    return data;
  }

  Future<void> refreshIfOld() async {
    if (lastFetched == null ||
        DateTime.now().difference(lastFetched!) > const Duration(minutes: 30)) {
      return refresh();
    }
    return;
  }

  Future<void> refresh() async {
    if (!ref.read(useMealsProvider)) {
      return;
    }

    state = const AsyncLoading();
    lastFetched = null;
    try {
      final meals = await stravaService.getMeals();
      lastFetched = DateTime.now();
      state = AsyncData(meals);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}
