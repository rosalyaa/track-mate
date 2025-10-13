import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:trackmate/admin_codebase/service/auth_service.dart';
import 'package:trackmate/admin_codebase/ui/home_page/home_page.dart';
import 'package:trackmate/driver_codebase/ui/drivers_app.dart';
import 'package:trackmate/student_codebase/ui/student_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // -------------------- STUDENT LOGIN --------------------
      final studentQuery = await _firestore.collection('students').get();

      final matchedStudentList = studentQuery.docs.where(
        (doc) =>
            (doc.data()['username'] ?? '').toString().toLowerCase() ==
                email.toLowerCase() &&
            (doc.data()['password'] ?? '').toString() == password,
      ).toList();

      if (matchedStudentList.isNotEmpty) {
        final matchedStudent = matchedStudentList.first;
        setState(() => _loading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => StudentHomePage(username: matchedStudent.data()['username']),
          ),
        );
        return;
      }

      // -------------------- DRIVER LOGIN --------------------
      final driverQuery = await _firestore.collection('drivers').get();

      final matchedDriverList = driverQuery.docs.where(
        (doc) =>
            (doc.data()['username'] ?? '').toString().toLowerCase() ==
                email.toLowerCase() &&
            (doc.data()['password'] ?? '').toString() == password,
      ).toList();

      if (matchedDriverList.isNotEmpty) {
        final matchedDriver = matchedDriverList.first;
        setState(() => _loading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DriverHomePage(driverId: matchedDriver.id),
          ),
        );
        return;
      }

      // -------------------- ADMIN LOGIN --------------------
      final adminUser =
          await _authService.signInWithEmailAndPassword(email, password);

      setState(() {
        _loading = false;
      });

      if (adminUser != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
        return;
      }

      // -------------------- INVALID LOGIN --------------------
      setState(() {
        _error = "Invalid username or password!";
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = "Error logging in: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 80, color: Colors.deepPurple),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Username / Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                if (_loading) const CircularProgressIndicator(),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red)),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding:
                            const EdgeInsets.symmetric(vertical: 15)),
                    child: const Text("Login",
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
