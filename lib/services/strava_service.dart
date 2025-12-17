import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
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

    await secureStorage.write(canteenCodeKey, canteenCode);
    await secureStorage.write(usernameKey, username);
    await secureStorage.write(passwordKey, password);

    if (password != '' && username != '') {
      await login();
    }

    return;
  }

  Future<String> get getCanteenCode async {
    return await secureStorage.read(canteenCodeKey);
  }

  Future<String> get getUsername async {
    return await secureStorage.read(usernameKey);
  }

  /// returns false if the user cant be logged in, true if they can be logged in or at least the canteenId is set
  Future<bool> login() async {
    String username = '';
    String password = '';
    try {
      canteenCode = await getCanteenCode;
      username = await getUsername;
      password = await secureStorage.read(passwordKey);
    } on Exception {
      throw AuthException(
        .couldntLogIn,
        exceptionAction: ExceptionActions.stravaLogin,
      );
    }

    if (canteenCode == '') {
      throw AuthException(
        .couldntLogIn,
        exceptionAction: ExceptionActions.stravaLogin,
      );
    }

    if( username == '' || password == ''){
      // The user can at least log in with canteenId
      return false;
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

    return true;
  }

  Future<void> logOut() async {
    _sid = null;
    _s5url = null;
    _ignoreCert = null;
    canteenCode = null;

    await secureStorage.write(canteenCodeKey, '');
    await secureStorage.write(usernameKey, '');
    await secureStorage.write(passwordKey, '');
  }

  Future<Map<Date, List<Meal>>> getMeals() async {
    final loggedIn = await login();
    if (!loggedIn) {
      return await getMealsNoLogin();
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

  Future<Map<Date, List<Meal>>> getMealsNoLogin() async {
    Map<Date, List<Meal>> meals = {};

    try {
      canteenCode = await secureStorage.read(canteenCodeKey);
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
