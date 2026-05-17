import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isAuthorized) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
