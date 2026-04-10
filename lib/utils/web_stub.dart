// Import on platforms other than web instead of web/web.dart

final window = Window();

class Window {
  final localStorage = LocalStorage();
}

class LocalStorage {
  void setItem(dynamic _, dynamic _) {}
}
