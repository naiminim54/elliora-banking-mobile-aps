import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'dart:convert';
import '../lib/api/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Configurer les assets pour les tests
    final testDir = Directory.current.path;
    final fixturesDir = path.join(testDir, 'lib', 'api', 'fixtures');

    // Enregistrer les fixtures comme des assets pour les tests
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
          final String key = utf8.decode(
            message!.buffer.asUint8List(
              message.offsetInBytes,
              message.lengthInBytes,
            ),
          );
          if (!key.startsWith('lib/api/fixtures/')) return null;

          final fileName = key.split('/').last;
          final file = File(path.join(fixturesDir, fileName));
          if (!await file.exists()) return null;

          final contents = await file.readAsBytes();
          return ByteData.view(Uint8List.fromList(contents).buffer);
        });
  });

  group('ApiClient', () {
    test('login devrait retourner un AuthResponse valide', () async {
      final response = await ApiClient.login('alice', 'password123');
      expect(response.token, equals('ey.mock.token'));
      expect(response.user.name, equals('Alice T.'));
    });

    test('getAccounts devrait échouer si non authentifié', () {
      ApiClient.setToken(null);
      expect(
        () => ApiClient.getAccounts(),
        throwsA(
          isA<ApiException>().having(
            (e) => e.statusCode,
            'statusCode',
            equals(401),
          ),
        ),
      );
    });

    test('getAccounts devrait retourner la liste des comptes', () async {
      await ApiClient.login('alice', 'password123');
      final accounts = await ApiClient.getAccounts();

      expect(accounts.length, equals(2));
      expect(accounts[0].type, equals('current'));
      expect(accounts[0].balance, equals(542300));
    });

    test(
      'getTransactions devrait retourner les transactions paginées',
      () async {
        await ApiClient.login('alice', 'password123');
        final response = await ApiClient.getTransactions('acc_1');

        expect(response.items.length, equals(2));
        expect(response.page, equals(1));
        expect(response.total, equals(2));
      },
    );

    test('transfer devrait retourner une confirmation', () async {
      await ApiClient.login('alice', 'password123');
      final response = await ApiClient.transfer(
        fromAccountId: 'acc_1',
        toAccountNumber: '1234567890',
        amount: 20000,
        currency: 'XAF',
        note: 'Paiement facture',
      );

      expect(response.transferId, equals('tr_123'));
      expect(response.status, equals('pending'));
    });

    test('logout devrait effacer le token', () async {
      await ApiClient.login('alice', 'password123');
      ApiClient.logout();

      expect(() => ApiClient.getAccounts(), throwsA(isA<ApiException>()));
    });
  });
}
