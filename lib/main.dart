import 'package:flutter/material.dart';
import 'signup_form.dart';
import 'login_form.dart';
import 'dashboard.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Grocery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.deepPurple,
      ),
      initialRoute: '/login',
      routes: {
        '/signup': (context) => const SignupPage(),
        '/login': (context) => const LoginPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final email = settings.arguments as String? ?? "Guest";
          return MaterialPageRoute(
            builder: (context) => DashboardPage(userEmail: email),
          );
        }
        return null;
      },
    ),
  );
}
