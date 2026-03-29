import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/bakalari/baka_hw_model.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/provider/bakalari/baka_login_notifier.dart';
import 'package:schoolarc/provider/exam_notifier.dart';
import 'package:schoolarc/provider/hw_notifier.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/utils/extensions/context_extension.dart';
import 'package:schoolarc/utils/globals.dart';

final bakaHomeworksAgeProvider = StreamProvider<Duration?>((ref) async* {
  final notifier = ref.watch(bakaHomeworksProvider.notifier);
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

final bakaHomeworksProvider =
    AsyncNotifierProvider<BakaHomeworksNotifier, List<BakaHomework>>(
      BakaHomeworksNotifier.new,
    );

class BakaHomeworksNotifier extends AsyncNotifier<List<BakaHomework>> {
  DateTime? lastFetched;
  bool isFetching = false;

  @override
  FutureOr<List<BakaHomework>> build() async {
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
  Future<List<BakaHomework>> _fetch() async {
    isFetching = true;

    final useBaka = ref.read(useBakaProvider);

    if (!useBaka) {
      throw DisabledException(.bakalariDisabled);
    }

    bool isLoggedIn = await ref.read(bakaLoginProvider.future);

    if (!isLoggedIn) {
      isLoggedIn = await ref.read(bakaLoginProvider.notifier).refreshLogin();
      if (!isLoggedIn) {
        throw ref.read(bakaLoginProvider).error ??
            AuthException(.loggedOut, exceptionAction: .bakaLogin);
      }
    }

    lastFetched = null;
    final data = await bakaService.getHomeworks();
    lastFetched = DateTime.now();
    _checkForNew(data);
    return data;
  }

  Future<void> refreshIfOld() async {
    if (lastFetched == null ||
        DateTime.now().difference(lastFetched!) > bakaPollingRate) {
      return refresh();
    }
    return;
  }

  /// Saves the bakahw as homework/exam, updates state of everything
  Future<void> import(BakaHomework hw, bool isHomework) async {
    if (isHomework) {
      await ref
          .read(hwDataProvider.notifier)
          .create(
            hw.toHwData().copyWith(
              timestamp: DateTime.now().toUtc(),
              isCompleted: false,
            ),
          );
    } else {
      await ref
          .read(examDataProvider.notifier)
          .create(hw.toExamData().copyWith(timestamp: DateTime.now().toUtc()));
    }

    final currentState = state.value;
    if (currentState != null) {
      final index = currentState.indexWhere(
        (element) => element.bakaId == hw.bakaId,
      );
      if (index != -1) {
        final updatedList = List.of(currentState);
        updatedList[index] = hw.copyWith(alreadyAdded: true);
        state = AsyncData(updatedList);
      }
    }
    await bakaHwDb.markAsAdded(hw.bakaId);
  }

  void _checkForNew(List<BakaHomework> hws) {
    int newHomeworks = 0;

    for (var element in hws) {
      if (!bakaHwDb.isSeen(element.id)) {
        newHomeworks++;
      }
    }

    if (newHomeworks != 0) {
      showNewHomeworksFoundMessage(newHomeworks);
    }
  }

  void showNewHomeworksFoundMessage(int count) {
    final context = navigatorKey.currentContext;
    if (context != null) {
      showMessage(
        context,
        context.loc.newHomeworkFound(count),
        isPersistent: true,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.restorablePushNamed(context, '/bakalari-homeworks');
              ScaffoldMessenger.of(context).clearSnackBars();
            },
            child: Text(context.loc.view),
          ),
        ],
      );
    }
  }
}
