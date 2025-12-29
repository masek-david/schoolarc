import 'package:flutter_test/flutter_test.dart';
import 'package:schoolarc/database/secure_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureStorage platform test', () {
    const key = 'testKey';
    final value = 'Saved at: ${DateTime.now()}';

    testWidgets('Write, read, delete', (WidgetTester tester) async {
      await SecureStorage.write(key, value);

      final read = await SecureStorage.read(key);
      expect(read, value);

      await SecureStorage.delete(key);
      final deleted = await SecureStorage.read(key);
      expect(deleted, isNull);
    });
  });
}
