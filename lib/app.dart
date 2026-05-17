import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/services/auth_api_service.dart';
import 'package:flutter_application_1/data/services/courses_api_service.dart';
import 'package:flutter_application_1/data/services/progress_api_service.dart';
import 'package:flutter_application_1/providers/auth_provider.dart';
import 'package:flutter_application_1/providers/profile_provider.dart';
import 'package:flutter_application_1/screens/auth_gate.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authApiService: const AuthApiService()),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(
            coursesApiService: const CoursesApiService(),
            progressApiService: const ProgressApiService(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Auth App',
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFEAE4DA),
          fontFamily: 'Roboto',
        ),
        home: const AuthGate(),
      ),
    );
  }
}
