import 'package:flutter/material.dart';
import 'signup_form.dart';
import 'login_form.dart';
import 'dashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;

          // Safely check arguments
          if (args != null && args is Map<String, dynamic>) {
            final email = args['email'] as String? ?? "Unknown User";
            return DashboardPage(userEmail: email);
          } else {
            // If no arguments provided, fallback
            return const DashboardPage(userEmail: "Guest");
          }
        },
      },
    );
  }
}
