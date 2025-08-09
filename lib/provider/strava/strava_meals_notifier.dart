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
  bool isFetching = false;

  @override
  FutureOr<Map<DateTime, List<Meal>>> build() async {
    _setupListeners();
    try {
      final data = await _fetch();
      return data;
    } finally {
      isFetching = false;
    }
  }

  /// listen to login and usemeals
  void _setupListeners() {
    ref.listen<bool>(useMealsProvider, (previous, next) {
      refresh();
    });

    ref.listen<AsyncValue<bool>>(stravaLoginProvider, (previous, next) {
      next.whenData((value) => refresh());
    });
  }

  /// Doesnt refresh if it is already fetching
  Future<void> refresh() async {
    if (isFetching) return;

    state = const AsyncLoading();
    try {
      final data = await _fetch();
      state = AsyncData(data);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
    isFetching = false;
  }

  /// Gets only if logged in and using meals
  Future<Map<DateTime, List<Meal>>> _fetch() async {
    isFetching = true;

    final useMeals = ref.read(useMealsProvider);
    final loc = getLocalization();

    if (!useMeals) {
      throw ServiceException(loc.mealsDisabled);
    }

    final isLoggedIn = await ref.read(stravaLoginProvider.future);

    if (!isLoggedIn) {
      throw ServiceException(
        loc.loggedOut,
        action: ExceptionActions.bakaLogin,
      );
    }

    lastFetched = null;
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
}
