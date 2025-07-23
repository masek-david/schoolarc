import 'package:flutter/material.dart';

@Deprecated('use context.isWide')
class ScreenSize {
  static ValueNotifier<bool> isWideScreen = ValueNotifier(false);
  static ValueNotifier<bool> isWiderThanTaller = ValueNotifier(false);

  static void init(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    isWideScreen.value = screenWidth > 600;

    isWiderThanTaller.value = screenWidth > screenHeight;
  }
}
