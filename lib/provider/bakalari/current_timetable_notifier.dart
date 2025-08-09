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

  @override
  FutureOr<TimeTable> build() async {
    final useBaka = ref.watch(useBakaProvider);
    final loc = getLocalization();

    if (!useBaka) {
      throw ServiceException(loc.bakalariDisabled);
    }

    final isLoggedIn = await ref.watch(bakaLoginProvider.future);

    if (!isLoggedIn) {
      throw ServiceException(
        loc.loggedOut,
        action: ExceptionActions.bakaLogin,
      );
    }

    final data = bakaService.getCurrentTimetable(DateTime.now());
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
    if (!ref.read(useBakaProvider)) {
      return;
    }

    state = const AsyncLoading();
    lastFetched = null;
    try {
      final timetable = await bakaService.getCurrentTimetable(DateTime.now());
      lastFetched = DateTime.now();
      state = AsyncData(timetable);
    } catch (e, s) {
      state = AsyncError(e, s);
    }
  }
}
