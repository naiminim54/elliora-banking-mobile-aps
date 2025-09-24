import 'dart:convert';
import 'package:http/http.dart' as http;

/// Fonctions utilitaires pour les appels API (GET/POST)
class ApiClient {
  // TODO: Adapter l'URL selon votre environnement de test
  // En développement local, remplacer par votre URL de backend Next.js
  static const String baseUrl = 'http://localhost:3000';

  static String? _token;

  /// Définit le token d'authentification
  static void setToken(String? token) {
    _token = token;
  }

  /// Headers par défaut
  static Map<String, String> get _defaultHeaders => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  /// Gère les réponses HTTP et les erreurs
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    } else {
      final errorBody = response.body.isNotEmpty
          ? json.decode(response.body)
          : {'message': 'Erreur inconnue'};

      throw ApiException(
        statusCode: response.statusCode,
        message: errorBody['message'] ?? 'Erreur inconnue',
      );
    }
  }

  /// POST /api/auth/login
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: _defaultHeaders,
      body: json.encode({'username': username, 'password': password}),
    );

    return _handleResponse(response);
  }

  /// GET /api/accounts
  static Future<List<dynamic>> getAccounts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/accounts'),
      headers: _defaultHeaders,
    );

    return _handleResponse(response);
  }

  /// GET /api/accounts/:accountId/transactions
  static Future<Map<String, dynamic>> getTransactions(
    String accountId, {
    int page = 1,
    int pageSize = 10,
    String? search,
    String? sortBy,
    String? sortOrder,
    String? type,
    String? startDate,
    String? endDate,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'pageSize': pageSize.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (sortBy != null) 'sortBy': sortBy,
      if (sortOrder != null) 'sortOrder': sortOrder,
      if (type != null) 'type': type,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    };

    final uri = Uri.parse(
      '$baseUrl/api/accounts/$accountId/transactions',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _defaultHeaders);

    return _handleResponse(response);
  }

  /// POST /api/transfer
  static Future<Map<String, dynamic>> transfer({
    required String fromAccountId,
    required String toAccountNumber,
    required double amount,
    String? description,
  }) async {
    final body = {
      'fromAccountId': fromAccountId,
      'toAccountNumber': toAccountNumber,
      'amount': amount,
    };

    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/transfer'),
      headers: _defaultHeaders,
      body: json.encode(body),
    );

    return _handleResponse(response);
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
