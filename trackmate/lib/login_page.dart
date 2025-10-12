import 'package:flutter/material.dart';
import 'package:trackmate/admin_codebase/service/auth_service.dart';
import 'package:trackmate/admin_codebase/ui/student_page/student_page.dart';
import 'package:trackmate/driver_codebase/ui/drivers_app.dart';
import 'package:trackmate/student_codebase/ui/student_page.dart';

import 'admin_codebase/ui/home_page/home_page.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;
  String? _error;

  // Dummy credentials
  final String driverEmail = "driver@sxcce.com";
  final String driverPassword = "driver123";

  final String studentEmail = "student@sxcce.com";
  final String studentPassword = "student123";

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // 1. Check if matches dummy Driver credentials
    if (email == driverEmail && password == driverPassword) {
      setState(() => _loading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DriverHomePage()),
      );
      return;
    }

    // 2. Check if matches dummy Student credentials
    if (email == studentEmail && password == studentPassword) {
      setState(() => _loading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const StudentHomePage()),
      );
      return;
    }

    // 3. Else, try Admin login via AuthService
    final user = await _authService.signInWithEmailAndPassword(email, password);

    setState(() {
      _loading = false;
    });

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()), // Admin panel
      );
    } else {
      setState(() {
        _error = "Invalid username or password!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            if (_loading) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _login,
              child: const Text("Login"),
            ),
          ],
        ),
      ),
    );
  }
}
