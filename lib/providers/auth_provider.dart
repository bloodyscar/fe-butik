import 'package:flutter/material.dart';
import '../models/auth_response.dart';
import '../models/user.dart';
import '../service/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoggedIn = false;
  User? _user;
  String? _token;
  String? _errorMessage;

  // Getters
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  User? get user => _user;
  String? get token => _token;
  String? get errorMessage => _errorMessage;

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Initialize auth state from session
  Future<void> initializeAuth() async {
    _setLoading(true);

    try {
      final session = await AuthService.getCurrentSession();
      if (session != null && session.isAuthenticated) {
        _isLoggedIn = true;
        _user = session.user;
        _token = session.token;
      } else {
        _isLoggedIn = false;
        _user = null;
        _token = null;
      }
    } catch (e) {
      _setError('Failed to initialize auth: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Login function
  Future<bool> login({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);

    try {
      final authResponse = await AuthService.login(
        email: email,
        password: password,
      );

      if (authResponse.isAuthenticated) {
        _isLoggedIn = true;
        _user = authResponse.user;
        _token = authResponse.token;
        _setLoading(false);
        return true;
      } else {
        _setError(authResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Login failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Register function
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final authResponse = await AuthService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      if (authResponse.success) {
        // Auto login after successful registration if token is provided
        if (authResponse.isAuthenticated) {
          _isLoggedIn = true;
          _user = authResponse.user;
          _token = authResponse.token;
        }
        _setLoading(false);
        return true;
      } else {
        _setError(authResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Registration failed: $e');
      _setLoading(false);
      return false;
    }
  }

  // Logout function
  Future<bool> logout() async {
    _setLoading(true);
    _setError(null);

    try {
      final authResponse = await AuthService.logout(token: _token);

      if (authResponse.success) {
        _isLoggedIn = false;
        _user = null;
        _token = null;
        _setLoading(false);
        return true;
      } else {
        _setError(authResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      // Even if API logout fails, clear local session
      await AuthService.logoutLocally();
      _isLoggedIn = false;
      _user = null;
      _token = null;
      _setError('Logout error: $e');
      _setLoading(false);
      return true; // Return true because local session is cleared
    }
  }

  // Get user profile
  Future<bool> getProfile() async {
    if (_token == null) return false;

    _setLoading(true);
    _setError(null);

    try {
      final authResponse = await AuthService.getProfile(token: _token!);

      if (authResponse.success && authResponse.user != null) {
        _user = authResponse.user;
        _setLoading(false);
        return true;
      } else {
        _setError(authResponse.message);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to get profile: $e');
      _setLoading(false);
      return false;
    }
  }
}
