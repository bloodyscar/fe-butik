import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/auth_response.dart';
import 'session_manager.dart';

class AuthService {
  // API base URL for authentication
  static const String _baseUrl = 'http://10.0.2.2:3000/users';

  // Register function with name, email, password, phone parameters
  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/create'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful - use fromJson for consistent parsing
        final responseData = jsonDecode(response.body);
        return AuthResponse.fromJson(responseData);
      } else {
        // Registration failed
        final errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Registration failed',
          errors: errorData['errors'] ?? {},
        );
      }
    } catch (e) {
      // Network or other error
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        errors: {'network': e.toString()},
      );
    }
  }

  // Login function with email and password parameters
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Login successful - use fromJson for consistent parsing
        final responseData = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(responseData);

        // Save session to SharedPreferences
        if (authResponse.isAuthenticated) {
          await SessionManager.saveSession(authResponse);
        }

        return authResponse;
      } else {
        // Login failed
        final errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Login failed',
          errors: errorData['errors'] ?? {},
        );
      }
    } catch (e) {
      // Network or other error
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        errors: {'network': e.toString()},
      );
    }
  }

  // Optional: Logout function
  static Future<AuthResponse> logout({String? token}) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add authorization header if token is provided
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      await SessionManager.clearSession();

      return AuthResponse(success: false, message: 'Berhasil Logout');
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        errors: {'network': e.toString()},
      );
    }
  }

  // Get user profile with JWT token
  static Future<AuthResponse> getProfile({required String token}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        User? user;

        if (responseData['user'] != null) {
          user = User.fromJson(responseData['user']);
        } else if (responseData['data'] != null) {
          user = User.fromJson(responseData['data']);
        }

        return AuthResponse(
          success: true,
          message: 'Profile retrieved successfully',
          user: user,
          token: token, // Keep the existing token
        );
      } else {
        final errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'Failed to get profile',
          errors: errorData['errors'] ?? {},
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
        errors: {'network': e.toString()},
      );
    }
  }

  // Check if user is currently logged in
  static Future<bool> isLoggedIn() async {
    return await SessionManager.isLoggedIn();
  }

  // Get current session
  static Future<AuthResponse?> getCurrentSession() async {
    return await SessionManager.getSession();
  }

  // Get current token
  static Future<String?> getCurrentToken() async {
    return await SessionManager.getToken();
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    return await SessionManager.getUser();
  }

  // Manual logout (clear session without API call)
  static Future<bool> logoutLocally() async {
    return await SessionManager.clearSession();
  }
}
