import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const String bakaRefreshTokenKey = 'bakaRefreshTokenKey';
  static const String bakaUsernameKey = 'bakaUserNameKey';
  static const String bakaSchoolNameKey = 'bakaSchoolUrlKey';

  static Future<String> read(String key) async {
    final value = await _storage.read(key: key) ?? '';
    return value;
  }

  static Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static void deleteAllFromDisk() {
    _storage.deleteAll();
  }
}
