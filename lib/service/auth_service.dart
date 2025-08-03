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

  // Get all users function
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      // Get current token for authentication
      final token = await SessionManager.getToken();
      
      final response = await http.get(
        Uri.parse('$_baseUrl/all'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Success - parse the response
        final responseData = jsonDecode(response.body);
        
        // Check if the response has a users array
        if (responseData['success'] == true && responseData['data'] != null) {
          List<User> users = [];
          
          // Parse users from the nested response structure
          if (responseData['data']['users'] != null) {
            users = (responseData['data']['users'] as List)
                .map((userData) => User.fromJson(userData))
                .toList();
          }
          
          return {
            'success': true,
            'message': responseData['message'] ?? 'Users retrieved successfully',
            'users': users,
            'pagination': responseData['data']['pagination'],
            'filter': responseData['data']['filter'],
          };
        } else {
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to retrieve users',
            'users': <User>[],
          };
        }
      } else {
        // Error response
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch users',
          'users': <User>[],
          'errors': errorData['errors'] ?? {},
        };
      }
    } catch (e) {
      // Network or other error
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
        'users': <User>[],
        'errors': {'network': e.toString()},
      };
    }
  }

  // Update user function with id, name, email, phone, password parameters
  static Future<AuthResponse> updateUsers({
    required int id,
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      // Get current token for authentication
      final token = await SessionManager.getToken();
      
      final response = await http.put(
        Uri.parse('$_baseUrl/edit/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        // Update successful
        final responseData = jsonDecode(response.body);
        return AuthResponse.fromJson(responseData);
      } else {
        // Update failed
        final errorData = jsonDecode(response.body);
        return AuthResponse(
          success: false,
          message: errorData['message'] ?? 'User update failed',
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

  // Delete user function with id parameter
  static Future<AuthResponse> deleteUsers({
    required int id,
  }) async {
    try {
      // Get current token for authentication
      final token = await SessionManager.getToken();
      
      final response = await http.delete(
        Uri.parse('$_baseUrl/delete/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Delete successful
        final responseData = response.body.isNotEmpty 
            ? jsonDecode(response.body) 
            : {'success': true, 'message': 'User deleted successfully'};
            
        return AuthResponse(
          success: true,
          message: responseData['message'] ?? 'User deleted successfully',
        );
      } else {
        // Delete failed
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? 'User deletion failed';
        
        // Handle specific database constraint errors
        if (errorData['error'] != null) {
          final error = errorData['error'];
          if (error is Map && error['code'] == 'ER_ROW_IS_REFERENCED_2') {
            if (error['sqlMessage'] != null && error['sqlMessage'].toString().contains('carts')) {
              errorMessage = 'Cannot delete user: User has items in cart. Please clear the cart first.';
            } else if (error['sqlMessage'] != null && error['sqlMessage'].toString().contains('orders')) {
              errorMessage = 'Cannot delete user: User has order history. User deletion not allowed.';
            } else {
              errorMessage = 'Cannot delete user: User has related data that must be removed first.';
            }
          } else if (error is Map && error['errno'] == 1451) {
            errorMessage = 'Cannot delete user: User has related data in the system.';
          }
        }
        
        return AuthResponse(
          success: false,
          message: errorMessage,
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
}
