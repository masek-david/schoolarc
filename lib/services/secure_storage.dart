import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();
  static const String bakaRefreshTokenKey = 'bakaRefreshTokenKey';
  static const String bakaUsernameKey = 'bakaUserNameKey';
  static const String bakaSchoolNameKey = 'bakaSchoolUrlKey';

  Future<String> read(String key) async {
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        return await _storage.read(key: key) ?? '';
      }
    }
    return '';
  }

  Future<void> write(String key, String value) async{
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        await _storage.write(key: key, value: value);
      }
    }
  }
}
