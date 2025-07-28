import 'user.dart';

class AuthResponse {
  final bool success;
  final String message;
  final User? user;
  final String? token;
  final Map<String, dynamic>? errors;

  AuthResponse({
    required this.success,
    required this.message,
    this.user,
    this.token,
    this.errors,
  });

  // Factory constructor to create AuthResponse from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    User? user;
    String? token;

    // Handle nested data structure
    if (json['data'] != null) {
      final data = json['data'] as Map<String, dynamic>;

      // Extract user from data.user
      if (data['user'] != null) {
        user = User.fromJson(data['user']);
      }

      // Extract token from data.token
      if (data['token'] != null) {
        token = data['token'] as String;
      }
    } else {
      // Fallback for direct structure
      if (json['user'] != null) {
        user = User.fromJson(json['user']);
      }
      token = json['token'] ?? json['access_token'];
    }

    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      user: user,
      token: token,
      errors: json['errors'],
    );
  }

  // Method to convert AuthResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'token': token,
      'errors': errors,
    };
  }

  // Check if the user is authenticated (has a valid token)
  bool get isAuthenticated => success && token != null && token!.isNotEmpty;

  @override
  String toString() {
    return 'AuthResponse{success: $success, message: $message, user: $user, token: ${token != null ? '***' : null},}';
  }
}
