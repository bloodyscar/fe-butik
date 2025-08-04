import 'package:butik_evanty/pages/admin/home_admin.dart';
import 'package:butik_evanty/pages/login_page.dart';
import 'package:butik_evanty/pages/user/main_navigation.dart';
import 'package:butik_evanty/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Initialize auth state when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).initializeAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          // Show loading screen while checking auth state
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading...'),
                ],
              ),
            ),
          );
        }

        if (authProvider.isLoggedIn) {
          // User is logged in, route based on role
          final userRole = authProvider.user?.role?.toLowerCase();

          if (userRole == 'admin') {
            return const HomeAdmin();
          } else {
            // Default to user home for 'user' role or any other role
            return const MainNavigation();
          }
        } else {
          // User is not logged in, show login page
          return const LoginPage();
        }
      },
    );
  }
}