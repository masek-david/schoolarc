import 'package:vibration/vibration.dart';

final primitiveClick = 5;
final primitiveTick = 5;

class Vibrate {
  final bool hasVibrator;

  Vibrate._(this.hasVibrator);

  static Future<Vibrate> create() async {
    final hasVibrator = await Vibration.hasVibrator();
    return Vibrate._(hasVibrator);
  }

  void _vibrate({required List<int> pattern, required List<int> intensities}) {
    if (hasVibrator) {
      Vibration.vibrate(pattern: pattern, intensities: intensities);
    }
  }

  void success() {
    _vibrate(
      pattern: [5, 55, 5],
      intensities: [178, 0, 255],
    );
  }

  void warning() {
    _vibrate(
      pattern: [5, 91, 5],
      intensities: [229, 0, 178],
    );
  }

  void error() {
    _vibrate(
      pattern: [5, 45, 5, 43, 5, 41, 5],
      intensities: [204, 0, 204, 0, 255, 0, 153],
    );
  }

  void light() {
    _vibrate(
      pattern: [3],
      intensities: [70],
    );
  }

  void medium() {
    _vibrate(
      pattern: [5],
      intensities: [204],
    );
  }

  void heavy() {
    _vibrate(
      pattern: [50, 120],
      intensities: [255, 8],
    );
  }

  void rigid() {
    _vibrate(
      pattern: [5],
      intensities: [229],
    );
  }

  void selection() {
    _vibrate(
      pattern: [2],
      intensities: [153],
    );
  }

  void release() {
    _vibrate(
      pattern: [250],
      intensities: [5],
    );
  }

  void complete(bool nowComplete) {
    if (nowComplete) {
      _vibrate(
        pattern: [20, 20, 20, 500, 300, 20, 20],
        intensities: [255, 120, 0, 5, 0, 255, 120],
      );
    } else {
      _vibrate(
        pattern: [20, 120],
        intensities: [255, 5],
      );
    }
  }

  void switchUI(bool nowOn) {
    // TODO remake
    if (nowOn) {
      _vibrate(
        pattern: [40, 20, 5],
        intensities: [10, 0, 100],
      );
    } else {
      _vibrate(
        pattern: [5, 20, 40],
        intensities: [100, 0, 10],
      );
    }
  }
}
