import 'package:flutter/foundation.dart';

void addLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(
      ['Roboto Serif Font'],
      'Roboto Serif\n\n'
      'Designed by Commercial Type, Greg Gazdowicz\n\n'
      'Copyright 2020 The Roboto Serif Project Authors\n\n'
      'Licensed under the SIL Open Font License, Version 1.1\n\n'
      'https://fonts.google.com/specimen/Roboto+Serif\n\n'
      'https://github.com/googlefonts/RobotoSerif',
    );
    yield const LicenseEntryWithLineBreaks(
      ['SVG Repo'],
      'Icons by Solar Icons\n\n'
      'Licensed under Creative Commons Attribution 4.0 (CC BY 4.0)\n\n'
      'Includes:\n\n'
      '• "Book Bookmark SVG" – https://www.svgrepo.com/svg/528059/book-bookmark\n\n'
      '• "Pen 2 SVG Vector" – https://www.svgrepo.com/svg/528446/pen-2\n\n'
      '• "Confetti SVG Vector" – https://www.svgrepo.com/svg/527656/confetti\n\n'
      'License: https://creativecommons.org/licenses/by/4.0/',
    );
  });
}
