import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';
import '../api/models.dart';

/// Service d'authentification (login, gestion token)
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Vérifie si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Récupère le token stocké
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Récupère les données utilisateur stockées
  static Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataStr = prefs.getString(_userKey);
    if (userDataStr != null) {
      try {
        final userData = json.decode(userDataStr);
        return User.fromJson(userData);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Connexion utilisateur
  static Future<AuthResponse> login(String username, String password) async {
    try {
      // Appel API de login
      final response = await ApiClient.login(username, password);

      // Stockage du token et des données utilisateur
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_tokenKey, response.token);
      await prefs.setString(
        _userKey,
        json.encode({
          'id': response.user.id,
          'name': response.user.name,
          'role': response.user.role,
        }),
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Déconnexion utilisateur
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    ApiClient.setToken(null);
  }

  /// Initialise le service (à appeler au démarrage de l'app)
  static Future<void> initialize() async {
    final token = await getToken();
    if (token != null) {
      ApiClient.setToken(token);
    }
  }
}
