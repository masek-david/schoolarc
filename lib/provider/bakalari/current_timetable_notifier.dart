import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/mock_data/mock_data.dart';
import 'package:schoolarc/models/bakalari/baka_timetable_model.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';
import 'package:schoolarc/provider/bakalari/baka_login_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
import 'package:schoolarc/utils/globals.dart';

final actualTimetableAgeProvider = StreamProvider.family<Duration?, int>((
  ref,
  week,
) async* {
  final notifier = ref.watch(actualTimetableDataProvider(week).notifier);
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

/// The Timetable with assigned subjects for weekSinceEpoch
final actualTimetableProvider = FutureProvider.family<Timetable, int>(
  (ref, week) async {
    if (MockData.useMock) {
      return MockData.actualTimetable;
    }

    final data = await ref.watch(actualTimetableDataProvider(week).future);
    final subjects = ref.watch(subjectsNonDeletedProvider);

    return data.toTimetable(subjects.values.toList());
  },
);

/// Actual BakaTimetable for weekSinceEpoch
final actualTimetableDataProvider =
    AsyncNotifierProvider.family<ActualTimetableNotifier, BakaTimetable, int>(
      ActualTimetableNotifier.new,
    );

class ActualTimetableNotifier extends AsyncNotifier<BakaTimetable> {
  DateTime? lastFetched;
  bool isFetching = false;
  final int week;

  ActualTimetableNotifier(this.week);

  @override
  FutureOr<BakaTimetable> build() async {
    _setupListeners();
    try {
      final data = await _fetch(canRefreshLogin: false);
      return data;
    } finally {
      isFetching = false;
    }
  }

  /// listen to login and useBaka
  void _setupListeners() {
    ref.listen<bool>(useBakaProvider, (previous, next) {
      refresh(canRefreshLogin: false);
    });

    ref.listen<AsyncValue<bool>>(bakaLoginProvider, (previous, next) {
      next.whenData((value) {
        return refresh(canRefreshLogin: false);
      });
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

  /// Gets only if logged in and using baka
  Future<BakaTimetable> _fetch({bool canRefreshLogin = true}) async {
    isFetching = true;

    final useBaka = ref.read(useBakaProvider);
    if (!useBaka) {
      throw DisabledException(.bakalariDisabled);
    }

    bool isLoggedIn;
    try {
      isLoggedIn = await ref.read(bakaLoginProvider.future);
    } on Exception {
      isLoggedIn = false;
    }

    if (!isLoggedIn && canRefreshLogin) {
      isLoggedIn = await ref.read(bakaLoginProvider.notifier).refreshLogin();
    }
    if (!isLoggedIn) {
      throw ref.read(bakaLoginProvider).error ??
          AuthException(.loggedOut, exceptionAction: .bakaLogin);
    }

    lastFetched = null;
    final data = await bakaService.getActualTimetable(week);
    lastFetched = DateTime.now();
    return data;
  }

  Future<void> refreshIfOld() async {
    if (lastFetched == null ||
        DateTime.now().difference(lastFetched!) > const Duration(minutes: 30)) {
      return refresh();
    }
  }
}
