import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:schoolarc/app_config.dart';
import 'package:schoolarc/firebase_options.dart';
import 'package:schoolarc/main.dart' as app;

Future<void> resetFirebase() async {
  await FirebaseAuth.instance.signOut();
}

Future<void> navigateToCloudSync(WidgetTester tester) async {
  // CLOSE TUTORIAL
  final closeButton = find.text('x');
  await tester.tap(closeButton);
  await tester.pump(const Duration(milliseconds: 100));

  // OPEN DRAWER
  final drawerButton = find.byIcon(Icons.menu);
  await tester.tap(drawerButton);
  await tester.pumpAndSettle();

  // OPEN SETTINGS
  final settingsButton = find.text('Settings');
  await tester.tap(settingsButton);
  await tester.pumpAndSettle();

  // OPEN CLOUD SYNC
  final cloudSyncButton = find.text('Cloud sync');
  await tester.tap(cloudSyncButton);
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  // for android emulator, could be localhost for windows,...
  final host = '10.0.2.2';

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // also should reset hive?

    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseDatabase.instance.useDatabaseEmulator(host, 9000);
  });

  setUp(
    () async {
      await resetFirebase();
    },
  );

  group('Firebase auth E2E tests', () {
    String email = 'test${DateTime.now().millisecondsSinceEpoch}@test.com';
    String password = '12345678';
    final authUrl =
        'http://$host:9099/emulator/v1/projects/school-903c8/oobCodes';

    testWidgets('Register and verify user', (
      tester,
    ) async {
      await app.main();
      await tester.pumpWidget(const ProviderScope(child: AppConfig()));

      await navigateToCloudSync(tester);

      // OPEN REGISTER PAGE
      final openRegisterPageButton = find.text('Register');
      await tester.tap(openRegisterPageButton);
      await tester.pumpAndSettle();

      // INPUT INFO
      await tester.enterText(find.byKey(const Key('Email')), email);
      await tester.enterText(find.byKey(const Key('Nickname')), 'TestNickname');
      await tester.enterText(find.byKey(const Key('Password')), password);
      await tester.enterText(
        find.byKey(const Key('Repeat password')),
        password,
      );
      await tester.pumpAndSettle();

      // REGISTER
      final registerButton = find.byKey(const Key('Register'));
      await tester.tap(registerButton);
      await tester.pumpAndSettle();

      final response = await http.get(Uri.parse(authUrl));
      final data = jsonDecode(response.body);

      final oobCodes = data['oobCodes'] as List;
      final myVerificationData = oobCodes.firstWhere(
        (code) =>
            code['email'] == email && code['requestType'] == 'VERIFY_EMAIL',
      );
      final verificationLink = myVerificationData['oobLink'].replaceAll(
        '127.0.0.1',
        '10.0.2.2',
      );
      await http.get(Uri.parse(verificationLink));

      final doneButton = find.text('Done');
      await tester.tap(doneButton);
      await tester.pumpAndSettle();

      expect(find.text('Email not verified'), findsNothing);
      expect(find.text(email), findsOneWidget);
    });
  });
}
