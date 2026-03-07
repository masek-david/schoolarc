import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/utils/globals.dart';

final stravaLoginProvider = AsyncNotifierProvider<StravaLoginNotifier, bool>(
  StravaLoginNotifier.new,
);

class StravaLoginNotifier extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() async {
    if (!ref.read(useMealsProvider)) {
      return false;
    }
    try {
      await stravaService.logIn();
      return true;
    } catch (e) {
      // If the user just isnt logged in with password, they can still be logged in with canteenId
      if (e is AuthException && e.code == .loggedOut) {
        return stravaService.hasCanteenIdSet();
      }
      rethrow;
    }
  }

  Future<bool> refreshLogin() async {
    state = const AsyncValue.loading();
    try {
      await stravaService.logIn();
    } catch (e, st) {
      if (e is AuthException && e.code == .loggedOut) {
        state = const AsyncData(false);
      } else {
        state = AsyncValue.error(e, st);
      }
      return false;
    }
    state = const AsyncValue.data(true);
    return true;
  }

  /// returns false if there were any errors
  Future<bool> register({
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
      return true;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return false;
    }
  }

  /// Returns true if successfully logged out
  Future<bool> logOut() async {
    state = const AsyncValue.loading();
    try {
      await stravaService.logOut();
      state = const AsyncValue.data(false);
      return true;
    } catch (e, stack) {
      state = AsyncError(e, stack);
      return false;
    }
  }
}
