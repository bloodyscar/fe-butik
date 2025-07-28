import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

import 'package:butik_evanty/models/auth_response.dart';
import 'package:butik_evanty/models/user.dart';
import 'package:butik_evanty/service/auth_service.dart';

void main() {
  // Integration Tests (These will actually call your API)
  // Uncomment and run these when your API server is running
  group('Live API Integration Tests', () {
    // WARNING: These tests will make actual API calls to your server
    // Make sure your API server is running on http://10.0.2.2:3000
    // before running these tests

    group('Register Integration Tests', () {
      test(
        'should register a new user successfully',
        () async {
          final result = await AuthService.register(
            name: 'Test User',
            email: 'test@example.com',
            password: 'password123',
            phone: '1234567890',
          );

          expect(result.success, true);
          expect(result.message, contains('successfully'));
          expect(result.user, isNotNull);
          expect(result.token, isNotNull);
          // expect(result.isAuthenticated, true);
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );

      test(
        'should fail to register with invalid email',
        () async {
          final result = await AuthService.register(
            name: 'Test User',
            email: 'invalid-email',
            password: 'password123',
            phone: '1234567890',
          );

          expect(result.success, false);
          expect(result.errors, isNotNull);
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );
    });

    group('Login Integration Tests', () {
      test(
        'should login with valid credentials',
        () async {
          // First register a user
          final email =
              'logintest${DateTime.now().millisecondsSinceEpoch}@example.com';
          final registerResult = await AuthService.register(
            name: 'Login Test User',
            email: email,
            password: 'password123',
            phone: '1234567890',
          );

          expect(registerResult.success, true);

          // Then try to login
          final loginResult = await AuthService.login(
            email: email,
            password: 'password123',
          );

          expect(loginResult.success, true);
          expect(loginResult.user?.email, email);
          expect(loginResult.token, isNotNull);
          expect(loginResult.isAuthenticated, true);
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );

      test(
        'should fail login with invalid credentials',
        () async {
          final result = await AuthService.login(
            email: 'nonexistent@example.com',
            password: 'wrongpassword',
          );

          expect(result.success, false);
          expect(result.isAuthenticated, false);
        },
        timeout: const Timeout(Duration(seconds: 30)),
      );
    });
  });
}
