import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import 'dart:convert';

class SessionManager {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save authentication session
  static Future<bool> saveSession(AuthResponse authResponse) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (authResponse.token != null) {
        await prefs.setString(_tokenKey, authResponse.token!);
      }

      if (authResponse.user != null) {
        await prefs.setString(
          _userKey,
          jsonEncode(authResponse.user!.toJson()),
        );
      }

      await prefs.setBool(_isLoggedInKey, authResponse.isAuthenticated);

      return true;
    } catch (e) {
      print('Error saving session: $e');
      return false;
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  // Get stored user data
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      }

      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;
      final token = prefs.getString(_tokenKey);

      // Return true only if both flag is true and token exists
      return isLoggedIn && token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Get complete session data
  static Future<AuthResponse?> getSession() async {
    try {
      final token = await getToken();
      final user = await getUser();
      final isLoggedIn = await SessionManager.isLoggedIn();

      if (isLoggedIn && token != null) {
        return AuthResponse(
          success: true,
          message: 'Session restored',
          user: user,
          token: token,
        );
      }

      return null;
    } catch (e) {
      print('Error getting session: $e');
      return null;
    }
  }

  // Clear session (logout)
  static Future<bool> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);

      return true;
    } catch (e) {
      print('Error clearing session: $e');
      return false;
    }
  }

  // Update user data (when profile is updated)
  static Future<bool> updateUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Check if token exists but don't validate expiration
  static Future<bool> hasToken() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking token: $e');
      return false;
    }
  }
}
