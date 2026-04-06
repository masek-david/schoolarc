import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schoolarc/utils/globals.dart';

final homePageProvider = NotifierProvider(HomePageNotifier.new);

class HomePageNotifier extends Notifier<int>{
  @override
  int build() {
    return settings.get(.initialAppPage);
  }

  void switchPage(int page){
    state = page;
  }
}