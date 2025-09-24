import 'package:intl/intl.dart';

/// Formatters pour monnaie/date (XAF)
class FormatUtils {
  /// Formatter pour les montants en XAF (Franc CFA)
  static final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'fr_CM',
    symbol: 'XAF',
    decimalDigits: 0,
  );

  /// Formatter pour les dates
  static final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');
  static final DateFormat _dateTimeFormatter = DateFormat('dd/MM/yyyy HH:mm');

  /// Formate un montant en devises
  static String formatCurrency(double amount, [String currency = 'FCFA']) {
    if (currency == 'FCFA' || currency == 'XAF') {
      return _currencyFormatter.format(amount);
    }
    // Pour les autres devises, format simple
    return '${amount.toStringAsFixed(0)} $currency';
  }

  /// Formate une date
  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  /// Formate une date avec l'heure
  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime);
  }

  /// Parse un montant depuis une string
  static double? parseAmount(String value) {
    try {
      // Nettoyer la chaîne mais conserver le signe négatif
      final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.parse(cleanValue);
    } catch (e) {
      return null;
    }
  }
}
