import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/l10n/my_localization.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';
import 'package:schoolarc/provider/bakalari/baka_login_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/utils/globals.dart';

final currentTimetableAgeProvider = StreamProvider<Duration?>((ref) async* {
  final notifier = ref.watch(currentTimetableProvider.notifier);
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

final currentTimetableProvider =
    AsyncNotifierProvider<CurrentTimetableNotifier, TimeTable>(
        CurrentTimetableNotifier.new);

class CurrentTimetableNotifier extends AsyncNotifier<TimeTable> {
  DateTime? lastFetched;
  bool isFetching = false;

  @override
  FutureOr<TimeTable> build() async {
    _setupListeners();
    try {
      final data = await _fetch();
      return data;
    } finally {
      isFetching = false;
    }
  }

  /// listen to login and useBaka
  void _setupListeners() {
    ref.listen<bool>(useBakaProvider, (previous, next) {
      refresh();
    });

    ref.listen<AsyncValue<bool>>(bakaLoginProvider, (previous, next) {
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

  /// Gets only if logged in and using baka
  Future<TimeTable> _fetch() async {
    isFetching = true;

    final useBaka = ref.read(useBakaProvider);
    final loc = getLocalization();

    if (!useBaka) {
      throw ServiceException(loc.bakalariDisabled);
    }

    bool isLoggedIn = await ref.read(bakaLoginProvider.future);

    if (!isLoggedIn) {
      isLoggedIn = await ref.read(bakaLoginProvider.notifier).refreshLogin();
      if (!isLoggedIn) {
        throw ServiceException(
          loc.loggedOut,
          action: ExceptionActions.bakaLogin,
        );
      }
    }

    lastFetched = null;
    final data = await bakaService.getCurrentTimetable(DateTime.now());
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
