import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:schoolarc/database/secure_storage.dart';
import 'package:schoolarc/models/date/date.dart';
import 'package:schoolarc/models/exception_model.dart';
import 'package:schoolarc/models/meal_model.dart';
import 'package:schoolarc/utils/globals.dart';
import 'package:schoolarc/utils/windows1250.dart';
import 'package:xml/xml.dart';

class StravaService {
  String? _sid;
  String? _s5url;
  bool? _ignoreCert;
  String? canteenCode;

  static const canteenCodeKey = 'canteenCode';
  static const usernameKey = 'stravaUsername';
  static const passwordKey = 'stravaPassword';

  /// saves the login info
  Future<void> registerUser({
    required String canteenCode,
    required String username,
    required String password,
  }) async {
    if (int.tryParse(canteenCode) == null) {
      throw ValidationException(.invalidCanteenNumber);
    }
    if (canteenCode.length != 4) {
      throw ValidationException(.invalidCanteenNumberLength);
    }

    await SecureStorage.write(canteenCodeKey, canteenCode);
    await SecureStorage.write(usernameKey, username);
    await SecureStorage.write(passwordKey, password);

    if (password != '' && username != '') {
      await logIn();
    }

    return;
  }

  Future<String> get getCanteenCode async {
    return await SecureStorage.read(canteenCodeKey);
  }

  Future<String> get getUsername async {
    return await SecureStorage.read(usernameKey);
  }

  /// Logs in the user with their canteenId, username and password.
  ///
  /// Throws [AuthException] with [AuthErrorCodes.loggedOut] if the user cant be logged in,
  /// this means they could still get meals with just the canteenId
  Future<void> logIn() async {
    String username = '';
    String password = '';
    try {
      canteenCode = await getCanteenCode;
      username = await getUsername;
      password = await SecureStorage.read(passwordKey);
    } on Exception {
      throw AuthException(
        .loggedOut,
        exceptionAction: ExceptionActions.stravaLogin,
      );
    }

    if (canteenCode == '' || username == '' || password == '') {
      throw AuthException(
        .loggedOut,
        exceptionAction: ExceptionActions.stravaLogin,
      );
    }

    Response response;
    try {
      response = await http
          .post(
            Uri.https('app.strava.cz', '/api/login'),
            body: jsonEncode({
              'cislo': canteenCode,
              'enviroment': 'W',
              'heslo': password,
              'jmeno': username,
              'lang': 'CZ',
              'zustatPrihlasen': false,
            }),
          )
          .timeout(timeoutDuration);
    } on SocketException catch (_) {
      throw NetworkException(.offline);
    } on TimeoutException catch (_) {
      throw NetworkException(.timeout);
    } catch (e) {
      throw NetworkException(.serverError, originalError: e);
    }

    if (response.statusCode != 200) {
      String message;
      try {
        message = jsonDecode(response.body)['message'];
      } on Object {
        message = response.reasonPhrase ?? 'Error';
      }
      throw ApiException(message);
    }

    final parsedJson = json.decode(response.body);

    _sid = parsedJson['sid'];
    _s5url = parsedJson['s5url'];
    _ignoreCert = parsedJson['ignoreCert'];
  }

  Future<void> logOut() async {
    _sid = null;
    _s5url = null;
    _ignoreCert = null;
    canteenCode = null;

    await SecureStorage.delete(canteenCodeKey);
    await SecureStorage.delete(usernameKey);
    await SecureStorage.delete(passwordKey);
  }

  Future<bool> hasCanteenIdSet() async {
    try {
      final id = await SecureStorage.read(canteenCodeKey);
      return id != '';
    } on Object {
      return false;
    }
  }

  Future<Map<Date, List<Meal>>> getMeals() async {
    bool loggedIn = _sid != null;
    if (!loggedIn) {
      try {
        await logIn();
        loggedIn = true;
      } catch (e) {
        await _getMealsNoLogin();
      }
    }
    if (!loggedIn) {
      return await _getMealsNoLogin();
    }

    Response response;
    try {
      response = await http
          .post(
            Uri.https('app.strava.cz', '/api/objednavky'),
            body: jsonEncode({
              'cislo': canteenCode,
              'sid': _sid,
              's5url': _s5url,
              'lang': 'CZ',
              'konto': 0,
              'podminka': '',
              'ignoreCert': _ignoreCert,
            }),
          )
          .timeout(timeoutDuration);
    } on SocketException catch (_) {
      throw NetworkException(.offline);
    } on TimeoutException catch (_) {
      throw NetworkException(.timeout);
    } catch (e) {
      throw NetworkException(.serverError, originalError: e);
    }

    Map<Date, List<Meal>> meals = {};

    if (response.reasonPhrase != "OK") {
      throw ApiException(response.reasonPhrase ?? 'Error');
    }

    final parsedJson = jsonDecode(response.body);

    for (final table in parsedJson.values) {
      for (final mealJson in table) {
        final date = Date.fromDateTime(
          DateFormat('dd.MM.yyyy').parse(mealJson['datum']),
        );

        final Meal meal = Meal(
          type: mealJson['druh_chod'],
          name: mealJson['nazev'],
          selected: mealJson['pocet'] != 0,
        );

        if (meals.containsKey(date)) {
          meals[date]!.add(meal);
        } else {
          meals.addAll({
            date: [meal],
          });
        }
      }
    }

    return meals;
  }

  Future<Map<Date, List<Meal>>> _getMealsNoLogin() async {
    Map<Date, List<Meal>> meals = {};

    try {
      canteenCode = await SecureStorage.read(canteenCodeKey);
    } on Exception {
      throw AuthException(
        .noCanteenId,
        exceptionAction: ExceptionActions.stravaLogin,
      );
    }

    if (canteenCode == '') {
      throw AuthException(
        .noCanteenId,
        exceptionAction: ExceptionActions.stravaLogin,
      );
    }

    final uri =
        'https://www.strava.cz/foxisapi/foxisapi.dll/istravne.istravne.process?xmljidelnickyA&zarizeni=$canteenCode&jazyk=CZ&httphlavicka=A%C2%A0';

    Response response;
    try {
      if (kIsWeb) {
        final encodedUri = Uri.encodeComponent(uri);
        response = await http
            .get(
              Uri.parse(
                'https://cors-proxy-one-olive.vercel.app/api/proxy?url=$encodedUri',
              ),
            )
            .timeout(timeoutDuration);
      } else {
        response = await http.get(Uri.parse(uri)).timeout(timeoutDuration);
      }
    } on SocketException catch (_) {
      throw NetworkException(.offline);
    } on TimeoutException catch (_) {
      throw NetworkException(.timeout);
    } catch (e) {
      throw NetworkException(.serverError, originalError: e);
    }

    if (response.statusCode != 200) {
      throw ApiException(response.reasonPhrase ?? 'Error');
    }

    final decoded = decodeWindows1250(response.bodyBytes);
    final document = XmlDocument.parse(decoded);
    final mealsXml = document.findAllElements('pomjidelnic_xmljidelnic');

    // Iterate over each meal and extract the required details
    for (var mealXml in mealsXml) {
      final dateXml = mealXml.findElements('datum').first.innerText;
      final type = mealXml.findElements('druh_popis').first.innerText;
      var name = mealXml.findElements('nazev').first.innerText;

      if (mealXml.findElements('druh').first.innerText == 'D') {
        name = mealXml.findElements('nazev').first.innerText;
      }

      final date = Date.fromDateTime(DateTime.parse(dateXml));

      final meal = Meal(type: type, name: name);

      if (meals.containsKey(date)) {
        meals[date]!.add(meal);
      } else {
        meals.addAll({
          date: [meal],
        });
      }
    }

    return meals;
  }
}
