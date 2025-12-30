import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/provider/settings_notifiers.dart';
import 'package:schoolarc/utils/globals.dart';

final bakaLoginProvider = AsyncNotifierProvider<BakaLoginNotifier, bool>(
  BakaLoginNotifier.new,
);

class BakaLoginNotifier extends AsyncNotifier<bool> {
  Timer? _tokenExpirationTimer;

  @override
  Future<bool> build() async {
    if (!ref.read(useBakaProvider)) {
      return false;
    }
    try {
      final result = await bakaService.refreshLogin();
      _tokenExpirationTime();
      return result;
    } catch (e) {
      // If the user is logged out, set state to false, else rethrow
      if (e is AuthException && e.code == .loggedOut) {
        return false;
      }
      rethrow;
    }
  }

  void _tokenExpirationTime() {
    final duration = bakaService.tokenExpiration?.difference(DateTime.now());

    if (duration == null) return;

    _tokenExpirationTimer?.cancel();
    _tokenExpirationTimer = Timer(
      duration,
      () {
        state = const AsyncValue.data(false);
      },
    );
  }

  Future<bool> refreshLogin() async {
    state = const AsyncValue.loading();

    try {
      await bakaService.refreshLogin();
    } catch (e, st) {
      if (e is AuthException && e.code == .loggedOut) {
        state = const AsyncData(false);
      } else {
        state = AsyncValue.error(e, st);
      }
      return false;
    }
    _tokenExpirationTime();
    state = const AsyncValue.data(true);
    return true;
  }

  Future<bool> firstLogin({
    required String school,
    required String username,
    required String password,
    required bool keepLoggedIn,
  }) async {
    state = const AsyncValue.loading();

    try {
      await bakaService.firstLogin(
        school: school,
        username: username,
        password: password,
        keepLoggedIn: keepLoggedIn,
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
    _tokenExpirationTime();
    state = const AsyncValue.data(true);
    return true;
  }

  /// Returns true if successfully logged out
  Future<bool> logOut() async {
    state = const AsyncValue.loading();

    try {
      await bakaService.logOut();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
    _tokenExpirationTimer?.cancel();
    state = const AsyncValue.data(false);
    return true;
  }
}
