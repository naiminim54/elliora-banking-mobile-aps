import 'dart:convert';
import 'package:flutter/services.dart';
import 'models.dart';

/// Client API mocké utilisant des fixtures JSON
class ApiClient {
  static const String baseUrl = 'https://api.mock.afric';
  static String? _token;

  // Simule un délai réseau
  static Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Charge un fichier fixture
  static Future<dynamic> _loadFixture(String name) async {
    await _simulateNetworkDelay();
    final String response = await rootBundle.loadString(
      'lib/api/fixtures/$name.json',
    );
    return json.decode(response);
  }

  /// Définit le token d'authentification
  static void setToken(String? token) {
    _token = token;
  }

  /// POST /auth/login
  static Future<AuthResponse> login(String username, String password) async {
    final json = await _loadFixture('auth_login');
    setToken(json['token']);
    return AuthResponse.fromJson(json);
  }

  /// GET /accounts
  static Future<List<Account>> getAccounts() async {
    if (_token == null)
      throw ApiException(statusCode: 401, message: 'Non authentifié');

    final List<dynamic> json = await _loadFixture('accounts');
    return json.map((item) => Account.fromJson(item)).toList();
  }

  /// GET /accounts/:accountId/transactions
  static Future<TransactionsResponse> getTransactions(
    String accountId, {
    int page = 1,
    int pageSize = 20,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (_token == null)
      throw ApiException(statusCode: 401, message: 'Non authentifié');

    final json = await _loadFixture('transactions');
    return TransactionsResponse.fromJson(json);
  }

  /// POST /transfer
  static Future<TransferResponse> transfer({
    required String fromAccountId,
    required String toAccountNumber,
    required int amount,
    required String currency,
    String? note,
  }) async {
    if (_token == null)
      throw ApiException(statusCode: 401, message: 'Non authentifié');

    final request = TransferRequest(
      fromAccountId: fromAccountId,
      toAccountNumber: toAccountNumber,
      amount: amount,
      currency: currency,
      note: note ?? '',
    );

    final json = await _loadFixture('transfer_response');
    return TransferResponse.fromJson(json);
  }

  /// Déconnexion
  static void logout() {
    setToken(null);
  }
}

/// Exception personnalisée pour les erreurs API
class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException: $message (Code: $statusCode)';
}
