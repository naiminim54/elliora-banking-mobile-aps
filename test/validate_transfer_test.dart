import 'package:flutter_test/flutter_test.dart';
import 'package:aps_mobile/utils/validate.dart';

void main() {
  group('ValidationUtils Tests', () {
    group('validateTransferAmount', () {
      test('should return null for valid amounts within balance', () {
        expect(ValidationUtils.validateTransferAmount(100, 1000), isNull);
        expect(ValidationUtils.validateTransferAmount(1000, 1000), isNull);
        expect(ValidationUtils.validateTransferAmount(0.01, 100), isNull);
      });

      test('should return error for amounts exceeding balance', () {
        expect(
          ValidationUtils.validateTransferAmount(1001, 1000),
          equals('Solde insuffisant'),
        );
        expect(
          ValidationUtils.validateTransferAmount(2000, 1000),
          equals('Solde insuffisant'),
        );
      });

      test('should return error for null or zero amounts', () {
        expect(
          ValidationUtils.validateTransferAmount(null, 1000),
          equals('Le montant doit être supérieur à 0'),
        );
        expect(
          ValidationUtils.validateTransferAmount(0, 1000),
          equals('Le montant doit être supérieur à 0'),
        );
        expect(
          ValidationUtils.validateTransferAmount(-100, 1000),
          equals('Le montant doit être supérieur à 0'),
        );
      });
    });

    group('validateAccountNumber', () {
      test('should return null for valid account numbers', () {
        expect(ValidationUtils.validateAccountNumber('1234567890'), isNull);
        expect(ValidationUtils.validateAccountNumber('ABCD1234567890'), isNull);
        expect(ValidationUtils.validateAccountNumber('1234567890ABCD'), isNull);
      });

      test('should return error for invalid account numbers', () {
        expect(
          ValidationUtils.validateAccountNumber(null),
          equals('Le numéro de compte est obligatoire'),
        );
        expect(
          ValidationUtils.validateAccountNumber(''),
          equals('Le numéro de compte est obligatoire'),
        );
        expect(
          ValidationUtils.validateAccountNumber('   '),
          equals('Le numéro de compte est obligatoire'),
        );
        expect(
          ValidationUtils.validateAccountNumber('123456789'),
          equals('Le numéro de compte doit contenir au moins 10 caractères'),
        );
      });
    });

    group('validateUsername', () {
      test('should return null for valid usernames', () {
        expect(ValidationUtils.validateUsername('admin'), isNull);
        expect(ValidationUtils.validateUsername('user123'), isNull);
        expect(ValidationUtils.validateUsername('test_user'), isNull);
      });

      test('should return error for invalid usernames', () {
        expect(
          ValidationUtils.validateUsername(null),
          equals('Le nom d\'utilisateur est obligatoire'),
        );
        expect(
          ValidationUtils.validateUsername(''),
          equals('Le nom d\'utilisateur est obligatoire'),
        );
        expect(
          ValidationUtils.validateUsername('   '),
          equals('Le nom d\'utilisateur est obligatoire'),
        );
      });
    });

    group('validatePassword', () {
      test('should return null for valid passwords', () {
        expect(ValidationUtils.validatePassword('password'), isNull);
        expect(ValidationUtils.validatePassword('123456'), isNull);
        expect(ValidationUtils.validatePassword('P@ssw0rd!'), isNull);
      });

      test('should return error for invalid passwords', () {
        expect(
          ValidationUtils.validatePassword(null),
          equals('Le mot de passe est obligatoire'),
        );
        expect(
          ValidationUtils.validatePassword(''),
          equals('Le mot de passe est obligatoire'),
        );
        expect(
          ValidationUtils.validatePassword('   '),
          equals('Le mot de passe est obligatoire'),
        );
      });
    });

    group('validateAmountInput', () {
      test('should return null for valid amount inputs', () {
        expect(ValidationUtils.validateAmountInput('100'), isNull);
        expect(ValidationUtils.validateAmountInput('1000.50'), isNull);
        expect(ValidationUtils.validateAmountInput('0.01'), isNull);
      });

      test('should return error for invalid amount inputs', () {
        expect(
          ValidationUtils.validateAmountInput(null),
          equals('Le montant est obligatoire'),
        );
        expect(
          ValidationUtils.validateAmountInput(''),
          equals('Le montant est obligatoire'),
        );
        expect(
          ValidationUtils.validateAmountInput('   '),
          equals('Le montant est obligatoire'),
        );
        expect(
          ValidationUtils.validateAmountInput('abc'),
          equals('Montant invalide'),
        );
        expect(
          ValidationUtils.validateAmountInput('0'),
          equals('Le montant doit être supérieur à 0'),
        );
        expect(
          ValidationUtils.validateAmountInput('-100'),
          equals('Le montant doit être supérieur à 0'),
        );
      });
    });
  });
}
