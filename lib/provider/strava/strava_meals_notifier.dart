import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/meal_model.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/strava/strava_login_notifier.dart';
import 'package:schoolarc/services/home_widget_service.dart';
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
    AsyncNotifierProvider<StravaMealsNotifier, Map<Date, List<Meal>>>(
      StravaMealsNotifier.new,
    );

class StravaMealsNotifier extends AsyncNotifier<Map<Date, List<Meal>>> {
  DateTime? lastFetched;
  bool isFetching = false;

  @override
  FutureOr<Map<Date, List<Meal>>> build() async {
    _setupListeners();
    try {
      final data = await _fetch(canRefreshLogin: false);
      return data;
    } finally {
      isFetching = false;
    }
  }

  /// listen to login and usemeals
  void _setupListeners() {
    ref.listen<bool>(useMealsProvider, (previous, next) {
      refresh(canRefreshLogin: false);
    });

    ref.listen<AsyncValue<bool>>(stravaLoginProvider, (previous, next) {
      next.whenData((value) => refresh(canRefreshLogin: false));
    });
  }

  /// Doesnt refresh if it is already fetching
  Future<void> refresh({bool canRefreshLogin = true}) async {
    if (isFetching) return;

    state = const AsyncLoading();
    try {
      final data = await _fetch(canRefreshLogin: canRefreshLogin);
      state = AsyncData(data);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
    isFetching = false;
  }

  /// Gets only if logged in and using meals
  Future<Map<Date, List<Meal>>> _fetch({bool canRefreshLogin = true}) async {
    isFetching = true;

    final useMeals = ref.read(useMealsProvider);
    if (!useMeals) {
      throw DisabledException(.mealsDisabled);
    }

    bool isLoggedIn;
    try {
      isLoggedIn = await ref.read(stravaLoginProvider.future);
    } on Exception {
      isLoggedIn = false;
    }

    if (!isLoggedIn && canRefreshLogin) {
      isLoggedIn = await ref.read(stravaLoginProvider.notifier).refreshLogin();
    }
    if (!isLoggedIn) {
      throw ref.read(stravaLoginProvider).error ??
          AuthException(.loggedOut, exceptionAction: .stravaLogin);
    }

    lastFetched = null;
    final data = await stravaService.getMeals();
    updateMealsWidget(data);
    lastFetched = DateTime.now();
    return data;
  }

  Future<void> refreshIfOld() async {
    if (lastFetched == null ||
        DateTime.now().difference(lastFetched!) > stravaPollingRate) {
      return refresh();
    }
    return;
  }
}
