import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/services/secure_storage.dart';
import 'package:school_manager/models/exception_model.dart';
import 'package:school_manager/models/meal_model.dart';
import 'package:xml/xml.dart';

class StravaService {
  String? sid;
  String? s5url;
  bool? ignoreCert;
  String? canteenCode;
  final storage = SecureStorage();

  final canteenCodeKey = 'canteenCode';
  final usernameKey = 'stravaUsername';
  final passwordKey = 'stravaPassword';

  void registerUser({
    required String canteenCode,
    required String username,
    required String password,
  }) {
    if (int.tryParse(canteenCode) == null) {
      throw ServiceException('Invalid canteen number');
    }
    if (canteenCode.length != 4) {
      throw ServiceException(
          'Invalid canteen number length, only allowed is 4');
    }

    storage.write(canteenCodeKey, canteenCode);
    storage.write(usernameKey, username);
    storage.write(passwordKey, password);
    return;
  }

  Future<String> get getCanteenCode async {
    return await storage.read(canteenCodeKey);
  }

  Future<String> get getUsername async {
    return await storage.read(usernameKey);
  }

  Future<void> login() async {
    String username = '';
    String password = '';
    try {
      canteenCode = await getCanteenCode;
      username = await getUsername;
      password = await storage.read(passwordKey);
    } on Exception {
      throw ServiceException(
        'Please log in',
        action: ExceptionActions.stravaLogin,
      );
    }

    if (canteenCode == '') {
      throw ServiceException('Canteen number is missing',
          action: ExceptionActions.stravaLogin);
    }
    if (username == '') {
      throw ServiceException('Username is missing',
          action: ExceptionActions.stravaLogin);
    }
    if (password == '') {
      throw ServiceException('Password is missing',
          action: ExceptionActions.stravaLogin);
    }

    Response response;
    try {
      response = await http.post(
        Uri.https('app.strava.cz', '/api/login'),
        body: jsonEncode({
          'cislo': canteenCode,
          'enviroment': 'W',
          'heslo': password,
          'jmeno': username,
          'lang': 'CZ',
          'zustatPrihlasen': false,
        }),
      );
    } on Exception {
      rethrow;
    }

    final parsedJson = json.decode(response.body);

    sid = parsedJson['sid'];
    s5url = parsedJson['s5url'];
    ignoreCert = parsedJson['ignoreCert'];

    return;
  }

  Future<Map<DateTime, List<Meal>>> getMeals() async {
    try {
      try {
        await login();
      } on Object {
        return await getMealsNoLogin();
      }
    } on SocketException catch (_) {
      throw ServiceException('Check your internet connection');
    } on Object {
      rethrow;
    }

    Response response;
    try {
      response = await http.post(
        Uri.https('app.strava.cz', '/api/objednavky'),
        body: jsonEncode({
          'cislo': canteenCode,
          'sid': sid,
          's5url': s5url,
          'lang': 'CZ',
          'konto': 0,
          'podminka': '',
          'ignoreCert': ignoreCert,
        }),
      );
    } on SocketException {
      throw ServiceException('Check your internet connection');
    } on Object {
      rethrow;
    }

    Map<DateTime, List<Meal>> meals = {};

    if (response.reasonPhrase != "OK") {
      throw ServiceException(response.reasonPhrase);
    }

    final parsedJson = jsonDecode(response.body);

    for (final table in parsedJson.values) {
      for (final mealJson in table) {
        final date = DateFormat('dd.MM.yyyy').parse(mealJson['datum']);

        final Meal meal = Meal(
          type: mealJson['druh_chod'],
          name: mealJson['druh'] == 'D'
              ? mealJson['delsiPopis']
              : mealJson['nazev'],
          selected: mealJson['pocet'] != 0,
        );

        if (meals.containsKey(date)) {
          meals[date]!.add(meal);
        } else {
          meals.addAll({
            date: [meal]
          });
        }
      }
    }

    return meals;
  }

  /// datetime in local at 0:00
  Future<Map<DateTime, List<Meal>>> getMealsNoLogin() async {
    Map<DateTime, List<Meal>> meals = {};

    try {
      canteenCode = await storage.read(canteenCodeKey);
    } on Exception {
      throw ServiceException('Please log in',
          action: ExceptionActions.stravaLogin);
    }

    if (canteenCode == '') {
      throw ServiceException('No canteen, please log in',
          action: ExceptionActions.stravaLogin);
    }
    
    final uri = Uri.parse(
        'https://www.strava.cz/foxisapi/foxisapi.dll/istravne.istravne.process?xmljidelnickyA&zarizeni=$canteenCode&jazyk=CZ&httphlavicka=A%C2%A0');

    Response response;
    try {
      response = await http.get(uri);
    } on SocketException {
      throw ServiceException('Check your internet connection');
    } on Object {
      rethrow;
    }

    if (response.reasonPhrase != "OK") {
      throw ServiceException(response.reasonPhrase);
    }

    final document = XmlDocument.parse(response.body);
    final mealsXml = document.findAllElements('pomjidelnic_xmljidelnic');

    // Iterate over each meal and extract the required details
    for (var mealXml in mealsXml) {
      final dateXml = mealXml.findElements('datum').first.innerText;
      final type = mealXml.findElements('druh_popis').first.innerText;
      var name = mealXml.findElements('nazev').first.innerText;

      if (mealXml.findElements('druh').first.innerText == 'D') {
        name = mealXml.findElements('popis').first.innerText;
      }

      final date = DateTime.parse(dateXml);

      final meal = Meal(
        type: fixEncode(type),
        name: fixEncode(name),
      );

      if (meals.containsKey(date)) {
        meals[date]!.add(meal);
      } else {
        meals.addAll({
          date: [meal]
        });
      }
    }

    return meals;
  }

  String fixEncode(String string) {
    return string
        .replaceAll('è', 'č')
        .replaceAll('È', 'Č')
        .replaceAll('', 'š')
        .replaceAll('', 'Š')
        .replaceAll('ø', 'ř')
        .replaceAll('ì', 'ě')
        .replaceAll('', 'ž')
        .replaceAll('ù', 'ů')
        // .replaceAll('í', 'á')
        .replaceAll('ò', 'ň');
  }
}
