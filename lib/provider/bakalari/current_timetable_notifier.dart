import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/timetable/timetable_model.dart';
import 'package:schoolarc/provider/bakalari/baka_login_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/provider/subject_notifier.dart';
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
      CurrentTimetableNotifier.new,
    );

class CurrentTimetableNotifier extends AsyncNotifier<TimeTable> {
  DateTime? lastFetched;
  bool isFetching = false;

  @override
  FutureOr<TimeTable> build() async {
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
  Future<TimeTable> _fetch({bool canRefreshLogin = true}) async {
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
    final data = await bakaService.getCurrentTimetable(Date.today());
    lastFetched = DateTime.now();
    return data;
  }

  Future<void> refreshIfOld() async {
    if (lastFetched == null ||
        DateTime.now().difference(lastFetched!) > const Duration(minutes: 30)) {
      return refresh();
    }
  }

  /// Reloads and reassigns all subjects for all lessons
  /// - use when subjects change and the subjects in the timetable should be updated
  /// todo: should listen to subjects provider??
  void reassignSubjects() {
    final timetable = state.value;
    if (timetable == null) return;

    final subjects = ref.read(subjectsNonDeletedProvider);
    subjects.removeWhere((key, value) => value.bakaId == null);
    final subjectsBakaId = subjects.map(
      (key, value) => MapEntry(value.bakaId!, value),
    );

    for (var dayIndex = 0; dayIndex < timetable.table.length; dayIndex++) {
      for (
        var lessonIndex = 0;
        lessonIndex < timetable.table[dayIndex].length;
        lessonIndex++
      ) {
        final lesson = timetable.table[dayIndex][lessonIndex];
        if (lesson.subject?.id == '') {
          final correctSubject = subjectsBakaId[lesson.subject?.bakaId];
          if (correctSubject != null) {
            timetable.table[dayIndex][lessonIndex] = lesson.copyWith(
              subject: correctSubject,
            );
          }
        }
      }
    }
    state = AsyncData(timetable);
  }
}
