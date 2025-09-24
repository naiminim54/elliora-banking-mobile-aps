import 'package:flutter_test/flutter_test.dart';
import 'package:aps_mobile/utils/format.dart';

void main() {
  group('FormatUtils Tests', () {
    test('formatCurrency should format amounts in XAF correctly', () {
      // Test formatage montants positifs - utiliser les espaces Unicode produits
      expect(FormatUtils.formatCurrency(1000), contains('1'));
      expect(FormatUtils.formatCurrency(1000), contains('000'));
      expect(FormatUtils.formatCurrency(1000), contains('XAF'));

      expect(FormatUtils.formatCurrency(50000), contains('50'));
      expect(FormatUtils.formatCurrency(50000), contains('000'));
      expect(FormatUtils.formatCurrency(50000), contains('XAF'));

      // Test montants négatifs
      expect(FormatUtils.formatCurrency(-1000), contains('-1'));
      expect(FormatUtils.formatCurrency(-1000), contains('XAF'));

      // Test zéro
      expect(FormatUtils.formatCurrency(0), equals('0 XAF'));
    });

    test('parseAmount should parse string amounts correctly', () {
      // Test parsing montants valides
      expect(FormatUtils.parseAmount('1000'), equals(1000.0));
      expect(FormatUtils.parseAmount('1000.50'), equals(1000.50));
      expect(FormatUtils.parseAmount('1 000 XAF'), equals(1000.0));
      expect(FormatUtils.parseAmount('1,500.75'), equals(1500.75));

      // Test parsing montants invalides
      expect(FormatUtils.parseAmount('abc'), isNull);
      expect(FormatUtils.parseAmount(''), isNull);
      expect(FormatUtils.parseAmount('1000abc'), equals(1000.0));
    });

    test('formatDate should format dates correctly', () {
      final testDate = DateTime(2023, 12, 25);
      expect(FormatUtils.formatDate(testDate), equals('25/12/2023'));
    });

    test('formatDateTime should format date and time correctly', () {
      final testDateTime = DateTime(2023, 12, 25, 14, 30);
      expect(
        FormatUtils.formatDateTime(testDateTime),
        equals('25/12/2023 14:30'),
      );
    });
  });
}
