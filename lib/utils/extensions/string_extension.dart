import 'package:school_manager/l10n/my_localization.dart';

extension DiacriticsAwareString on String {
  static const diacritics =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËĚèéêëěðČÇçčÐĎďÌÍÎÏìíîïĽľÙÚÛÜŮùúûüůŇÑñňŘřŠšŤťŸÝÿýŽž';
  static const nonDiacritics =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEEeeeeeeCCccDDdIIIIiiiiLlUUUUUuuuuuNNnnRrSsTtYYyyZz';

  String get withoutDiacriticalMarks => splitMapJoin('',
      onNonMatch: (char) => char.isNotEmpty && diacritics.contains(char)
          ? nonDiacritics[diacritics.indexOf(char)]
          : char);

  String sanitizeHtml() {
    return replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll('\'', '&#39;');
  }

  String camelToSentence() {
    return replaceAllMapped(RegExp(r'^([a-z])|[A-Z]'),
        (Match m) => m[1] == null ? " ${m[0]}" : m[1]!.toUpperCase());
  }

  String capitalize() {
    return this[0].toUpperCase() + substring(1);
  }

  String toVocative() {
    if(getLocale().languageCode != 'cs') return this;
    
    final name = trim();

    if (name.isEmpty) return name;

    final lowerName = name.toLowerCase();

    if (lowerName.endsWith('a')) {
      return '${name.substring(0, name.length - 1)}o';
      // Např. Anna -> Anno
    } else if (lowerName.withoutDiacriticalMarks.endsWith('ek')) {
      return '${name.substring(0, name.length - 2)}ku';
      // Např. Radek -> Radku
    } else if (lowerName.endsWith('el')) {
      return '${name.substring(0, name.length - 2)}le';
      // Např. Karel -> Karle
    } else if (lowerName.endsWith('al')) {
      return '${name}e';
      // Např. Michal -> Michale
    } else if (lowerName.endsWith('ch') || lowerName.endsWith('k')) {
      return '${name}u';
      // Např. vojtech -> vojtechu
    } else if (lowerName.endsWith('r')) {
      return '${name.substring(0, name.length - 1)}ře';
      // Např. Petr -> Petře
    } else if (lowerName.endsWith('š') || lowerName.endsWith('j')) {
      return '${name}i';
      // Např. Tomáš -> Tomáši
    } else if (lowerName.endsWith('b') ||
        lowerName.endsWith('d') ||
        lowerName.endsWith('m') ||
        lowerName.endsWith('f') ||
        lowerName.endsWith('p') ||
        lowerName.endsWith('v') ||
        lowerName.endsWith('l') ||
        lowerName.endsWith('n') ||
        lowerName.endsWith('t')) {
      return '${name}e';
      // Např. Jakub -> Jakube
    } else {
      return name; // fallback
    }
  }
}
