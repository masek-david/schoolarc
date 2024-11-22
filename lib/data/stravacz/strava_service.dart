import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:school_manager/data/safe_box.dart';
import 'package:school_manager/data/stravacz/meal_model.dart';
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
      throw Exception('Invalid canteen number:');
    }
    if (canteenCode.length != 4) {
      throw Exception('Invalid canteen number length, only allowed is 4');
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
    String username = await storage.read(usernameKey);
    String password = await storage.read(passwordKey);
    canteenCode = await getCanteenCode;

    if (canteenCode == '') {
      throw Exception('Canteen number is missing');
    }
    if (username == '') {
      throw Exception('Username is missing');
    }
    if (password == '') {
      throw Exception('Password is missing');
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
          .timeout(const Duration(seconds: 10));
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
      await login();
    } on Exception {
      return await getMealsNoLogin();
    }

    Response response;
    try {
      response = await http
          .post(
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
          )
          .timeout(const Duration(seconds: 10));
    } on Exception {
      rethrow;
    }

    Map<DateTime, List<Meal>> meals = {};

    if (response.reasonPhrase != "OK") {
      throw Exception(response.reasonPhrase);
    }

    final parsedJson = jsonDecode(response.body);

    for (final table in parsedJson.values) {
      for (final mealJson in table) {
        final date = DateFormat('dd.MM.yyyy').parse(mealJson['datum']);

        final Meal meal = Meal(
          type: mealJson['druh_chod'],
          name: mealJson['nazev'],
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

    canteenCode = await storage.read(canteenCodeKey);

    if (canteenCode == '') {
      throw Exception('No canteen');
    }

    final uri = Uri.parse(
        'https://www.strava.cz/foxisapi/foxisapi.dll/istravne.istravne.process?xmljidelnickyA&zarizeni=$canteenCode&jazyk=CZ&httphlavicka=A%C2%A0');

    Response response;
    try {
      response = await http.get(uri).timeout(const Duration(seconds: 10));
    } on Exception {
      rethrow;
    }

    if (response.reasonPhrase != "OK") {
      throw Exception(response.reasonPhrase);
    }

    final document = XmlDocument.parse(response.body);
    final mealsXml = document.findAllElements('pomjidelnic_xmljidelnic');

    // Iterate over each meal and extract the required details
    for (var mealXml in mealsXml) {
      final dateXml = mealXml.findElements('datum').first.innerText;
      final type = mealXml.findElements('druh_popis').first.innerText;
      final name = mealXml.findElements('nazev').first.innerText;

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
        .replaceAll('', 'š')
        .replaceAll('ø', 'ř')
        .replaceAll('È', 'Č')
        .replaceAll('ì', 'ě')
        .replaceAll('', 'ž')
        .replaceAll('ù', 'ů')
        // .replaceAll('í', 'á')
        .replaceAll('ò', 'ň');
  }
}
