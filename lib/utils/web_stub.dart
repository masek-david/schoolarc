// Import on platforms other than web instead of web/web.dart

final window = Window();

class Window {
  final localStorage = LocalStorage();
}

class LocalStorage {
  void setItem(dynamic _, dynamic _) {}
}

class Vibration {
  Vibration({required this.duration, required this.intensity});

  final int duration;
  final double intensity;
}

class WebHaptics {
  WebHaptics();

  void trigger(List<Vibration> _){}
}
