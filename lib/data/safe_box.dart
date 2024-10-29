import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const String bakaRefreshTokenKey = 'bakaRefreshTokenKey';
  static const String bakaUsernameKey = 'bakaUserNameKey';
  static const String bakaSchoolNameKey = 'bakaSchoolUrlKey';

  Future<String> read(String key) async {
    return await _storage.read(key: key) ?? '';
  }

  void write(String key, String value) {
    _storage.write(key: key, value: value);
  }
}
