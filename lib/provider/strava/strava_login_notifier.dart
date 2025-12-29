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
    if (ref.read(useMealsProvider)) {
      try {
        await stravaService.logIn();
        return true;
      } catch (e) {
        if (e is NetworkException && e.code == .offline) {
          rethrow;
        }
        if (e is AuthException && e.code == .loggedOut) {
          return stravaService.hasCanteenIdSet();
        }
        return false;
      }
    } else {
      return false;
    }
  }

  Future<bool> refreshLogin() async {
    state = const AsyncValue.loading();
    try {
      await stravaService.logIn();
    } catch (e, stack) {
      state = AsyncError(e, stack);
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
