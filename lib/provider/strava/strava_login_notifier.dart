import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/utils/globals.dart';

final stravaLoginProvider =
    AsyncNotifierProvider<StravaLoginNotifier, bool>(StravaLoginNotifier.new);

class StravaLoginNotifier extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    if (ref.read(useMealsProvider)) {
      try {
        await stravaService.login();
        return true;
      } catch (e, stack) {
        state = AsyncError(e, stack);
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> refreshLogin() async {
    state = const AsyncValue.loading();
    try {
      await stravaService.login();
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return false;
    }
    state = const AsyncValue.data(true);
    return true;
  }

  Future<void> register({
    required String canteenCode,
    required String username,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      await stravaService.registerUser(
        canteenCode: canteenCode,
        username: username,
        password: password,
      );
      state = const AsyncValue.data(true);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }

  Future<void> logOut() async {
    state = const AsyncValue.loading();
    try {
      await stravaService.logOut();
      state = const AsyncValue.data(false);
    } catch (e, stack) {
      state = AsyncError(e, stack);
    }
  }
}
